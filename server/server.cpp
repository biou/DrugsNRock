#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include <map>
#include <set>
#include <string>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <unistd.h>
#include <errno.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include <jsoncpp/json/json.h>

using namespace std;

/*
 Makefile:
 
 server: server.cpp Makefile
 g++ -Wall -g -o server  server.cpp -lpthread -ljsoncpp -lrt
 */

//pb:
//- blocage si client répond pas apres accept
//- taille des noms



string int2str(int i)
{
	char s[50];
	snprintf(s,50,"%d",i);
	return s;
}


pthread_mutex_t mainmutex;
typedef long long ll_t;

void error(const char *msg)
{
	perror(msg);
	exit(1);
}

void lock() {
	pthread_mutex_lock(&mainmutex);
}

void unlock() {
	pthread_mutex_unlock(&mainmutex);
}

//#define lock() {fprintf(stderr,"lock %s:%d: %s.\n",__FILE__,__LINE__,__PRETTY_FUNCTION__); _lock();}
//#define unlock() {fprintf(stderr,"unlock %s:%d: %s.\n",__FILE__,__LINE__,__PRETTY_FUNCTION__); _unlock();}

#define LOG_NORMAL 2
#define LOG_DEBUG 4
FILE *log_out=stderr;
int log_level=LOG_DEBUG;

#define log(...) {if(log_level>=LOG_NORMAL) {/*printf ( __VA_ARGS__);*/ if(log_out) fprintf(log_out,__VA_ARGS__);}}
#define debug(...) {if(log_level>=LOG_DEBUG) {/*printf ( __VA_ARGS__);*/ if(log_out) {fprintf(log_out,"\e[1m\e[32m");fprintf(log_out,__VA_ARGS__);fprintf(log_out,"\e[1m\e[0m");}}}

struct client_t {
	int fd;
	string name;
	bool ready;
	int bpm;
	int changebpm;
	int state; //-1..1
	client_t() {
		ready=false;
		state=0;
	}
	void addbpm(int i) {
		bpm+=i;
		changebpm=1;
	}
	void setbpm(int i) {
		bpm=i;
		changebpm=1;
	}
};


int nbrclients=0;
map<int,client_t> clients;
set<int> players;

void clientwrite(int i,const char *s)
{
	debug("send to %d : '%s'\n",i,s);
	int n = write(clients[i].fd,s,strlen(s));
}

void sendbpm(int i,int bpm) {
	//printf("changebpm %d : %d\n",i,bpm);
	char bf[100];
	snprintf(bf,100,"{\"bpm\":\"%d\"}\n",bpm);
	clientwrite(i,bf);
}

void sendstart(int i) {
	char bf[100];
	snprintf(bf,100,"{\"start\":\"1\"}\n");
	clientwrite(i,bf);
}

void sendend(int i,bool status) {
	char bf[100];
	snprintf(bf,100,"{\"end\":\"%d\"}\n",status);
	clientwrite(i,bf);
}

void sendobj(int i,int obj) {
	char bf[100];
	const char *objt[2]={"join","exta"};
	snprintf(bf,100,"{\"newobj\":\"%s\"}\n",objt[obj]);
	clientwrite(i,bf);
}

void sendmsg(int i,const string &name,const string &val="1",const string &s2="", const string &v2="1")
{
	char bf[100];
	if(s2!="") {
		snprintf(bf,100,"{\"%s\":\"%s\",\"%s\":\"%s\"}\n",name.c_str(),val.c_str(),s2.c_str(),v2.c_str());
	} else {
		snprintf(bf,100,"{\"%s\":\"%s\"}\n",name.c_str(),val.c_str());
	}
	clientwrite(i,bf);
}

void closeall() {
	lock();
	for(int i=0;i<nbrclients;i++) {
		close(clients[i].fd);
	}
	clients.clear();
	nbrclients=0;
	players.clear();
	unlock();
}


void removeclient(int i)
{
	lock();
	sendmsg(i,"bye");
	close(clients[i].fd);
	clients.erase(i);
	players.erase(i);
	unlock();
}

void closeall(const set<int> &s) {
	for(set<int>::const_iterator it=s.begin();it!=s.end();++it)
		removeclient(*it);
}

void updatewaitplayers() {
	int waiting=0;
	for(map<int,client_t>::iterator it=clients.begin();it!=clients.end();++it) {
		if(players.find(it->first)==players.end()  ) {
			waiting++;
		}
	}
	for(map<int,client_t>::iterator it=clients.begin();it!=clients.end();++it) {
		if(players.find(it->first)==players.end()) {
			sendmsg(it->first,"totalplayers",int2str(waiting));
		}
	}
}

void *tcpserv(void*)
{
	int sockfd, newsockfd, portno;
	socklen_t clilen;
	char buffer[256];
	struct sockaddr_in serv_addr, cli_addr;
	int n;
	struct timeval timeout;
	
	while(1) {
		sockfd = socket(AF_INET, SOCK_STREAM, 0);
		if (sockfd < 0) {
			perror("ERROR opening socket");
			goto retry;
		}
		bzero((char *) &serv_addr, sizeof(serv_addr));
		portno = 1337;
		serv_addr.sin_family = AF_INET;
		serv_addr.sin_addr.s_addr = INADDR_ANY;
		serv_addr.sin_port = htons(portno);
		if (bind(sockfd, (struct sockaddr *) &serv_addr,
				 sizeof(serv_addr)) < 0) {
			perror("ERROR on binding");
			close(sockfd);
			goto retry;
		}
		
		listen(sockfd,5);
		
		debug("listen");
		
		while(1) {
			clilen = sizeof(cli_addr);
			newsockfd = accept(sockfd,
							   (struct sockaddr *) &cli_addr,
							   &clilen);
			if (newsockfd < 0) {
				perror("ERROR on accept");
				if(errno!=EAGAIN) {
					close(sockfd);
					goto retry;
				}
				sleep(1);
				continue;
			}
			bzero(buffer,256);
			debug("accept returns %d\n",newsockfd);
			n = read(newsockfd,buffer,255);
			if (n < 0) error("ERROR reading from socket");
			debug("< '%s'\n",buffer);
			
#if 0
			if(strncmp(buffer,"WIENER",6)) {
				debug("bad password\n");
				close(newsockfd);
				continue;
			}
			char name[100];
			strncpy(name,buffer+7,100);
#else
			Json::Value root;
			Json::Reader reader;
			bool parsingSuccessful = reader.parse( buffer, root );
			if ( !parsingSuccessful ) {
				std::cout  << "Failed to parse configuration\n"
				<< reader.getFormattedErrorMessages();
				close(newsockfd);
				continue;
			}
			
			string name = root.get("wiener", "" ).asString();
			if(name=="") {
				debug("bad wiener\n");
				char welcome[]="{\"goaway\":\"1\"}\n";
				n = write(newsockfd,welcome,strlen(welcome));
				close(newsockfd);
				continue;
			}
			
			log("connexion from %s. name : %s\n",inet_ntoa(cli_addr.sin_addr),name.c_str());
			
#endif
			debug("send welcome to %s\n",name.c_str());
			char welcome[]="{\"welcome\":\"1\"}\n";
			n = write(newsockfd,welcome,strlen(welcome));
			if (n < 0) {
				perror("ERROR writing to socket");
				close(newsockfd);
				continue;
			}
			timeout.tv_sec = 0;
			timeout.tv_usec = 1000;
			if (setsockopt (newsockfd , SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout,
							sizeof(timeout)) < 0) {
				perror("setsockopt failed\n");
				close(newsockfd);
				continue;
			}
			
			timeout.tv_sec = 0;
			timeout.tv_usec = 10000;
			if (setsockopt (newsockfd , SOL_SOCKET, SO_SNDTIMEO, (char *)&timeout,
							sizeof(timeout)) < 0) {
				perror("setsockopt failed\n");
				close(newsockfd);
				continue;
			}
			
			debug("connected %d\n",int(newsockfd));
			
			lock();
			client_t c;
			c.name=name;
			c.fd=newsockfd;
			
			int i=nbrclients;
			clients[nbrclients++]=c;
			
			for(map<int,client_t>::iterator it=clients.begin();it!=clients.end();++it) {
				if(players.find(it->first)==players.end()) {
					if(i!=it->first)
						sendmsg(it->first,"newplayer",name,"id",int2str(i));
				}
			}
			
			updatewaitplayers();
			
			
			/*
			 if(::sockfd>=0) {
			 close(::sockfd);
			 }
			 ::sockfd=newsockfd;
			 */
			
			unlock();
			//lastcon=time(NULL);
			
			debug("client %d OK\n",int(newsockfd));
		}
	retry:
		sleep(2);
	}
	close(sockfd);
	return NULL;
}

struct game_t;

bool process(int ic, const string &s, game_t *g=NULL);
bool readclient(int i,game_t *g=NULL);

typedef enum
{
    ItemTypeNormal,
    ItemTypeGHB,
    ItemTypeLSD,
    ItemTypeHero,
    ItemTypeCanna,
    ItemTypeTramadol,
    ItemTypeAlcool,
    ItemTypeOpium,
    ItemTypeCocaine,
    ItemTypeCafe,
    ItemTypeChampi,
    ItemTypeMeth,
    ItemTypeExta,
    ItemEnd
} ItemType;

string titems[] =
{
    "ItemTypeNormal",
    "ItemTypeGHB",
    "ItemTypeLSD",
    "ItemTypeHero",
    "ItemTypeCanna",
    "ItemTypeTramadol",
    "ItemTypeAlcool",
    "ItemTypeOpium",
    "ItemTypeCocaine",
    "ItemTypeCafe",
    "ItemTypeChampi",
    "ItemTypeMeth",
    "ItemTypeExta",
    "ItemEnd"
};

string getitemname(int i){
	if(i>=0 && i<sizeof(titems)/sizeof(titems[0])) return titems[i];
	return "invalid";
}

ItemType getitem(int i) {
	switch(i) {
		case 0: return ItemTypeAlcool;
		case 1: return ItemTypeCafe;
		case 2: return ItemTypeExta;
		case 3: return ItemTypeCanna;
		case 4: return ItemTypeTramadol;
		case 5: return ItemTypeChampi;
		case 6: return ItemTypeCocaine;
		case 7: return ItemTypeOpium;
		case 8: return ItemTypeMeth;
		case 9: return ItemTypeHero;
		case 10: return ItemTypeGHB;
		case 11: return ItemTypeLSD;
	}
	return ItemTypeAlcool;
}

int getdelta(const ItemType &type)
{
	int effect = 0;
	
	switch (type) {
		case ItemTypeGHB:
			effect = 0;
			break;
		case ItemTypeLSD:
			effect = 0;
			break;
		case ItemTypeHero:
			effect = -10;
			break;
		case ItemTypeCanna:
			effect = -7;
			break;
		case ItemTypeTramadol:
			effect = -5;
			break;
		case ItemTypeAlcool:
			effect = -3;
			break;
		case ItemTypeOpium:
			effect = -9;
			break;
		case ItemTypeCocaine:
			effect = +8;
			break;
		case ItemTypeCafe:
			effect = +3;
			break;
		case ItemTypeChampi:
			effect = +4;
			break;
		case ItemTypeMeth:
			effect = +10;
			break;
		case ItemTypeExta:
			effect = +5;
			break;
			
		default:
			break;
	}
	
	return effect;
}

int getdelta(int i)
{
	return getdelta(ItemType(i));
}

int abs(int i)
{
	if(i<0) return -i;
	return i;
}

struct game_t {
	struct timespec time_ts;
	
	pthread_t th;
	
	void TIME_START() {
		clock_gettime(CLOCK_REALTIME, &time_ts);
	}
	
	double TIME() {
		struct timespec ts;
		clock_gettime(CLOCK_REALTIME, &ts);
		ll_t st=time_ts.tv_nsec+1000000000LL*time_ts.tv_sec;
		ll_t en=ts.tv_nsec+1000000000LL*ts.tv_sec;
		return (en-st)/1000000000.;
	}
	
	int ismechant(int bpm,int delta) {
		if(bpm+delta>220 || bpm+delta<50) {
			return 9;
		}
		if(bpm>180) {
			if(delta>5)
				return 7;
			if(delta>0)
				return 4;
			if(delta<5)
				return -7;
			if(delta<5)
				return -4;
		}
		if(bpm<70) {
			if(delta<-5)
				return 7;
			if(delta<0)
				return 4;
			if(delta>5)
				return -7;
			if(delta>0)
				return -4;
		}
		if(bpm>120) {
			if(delta>5)
				return 7;
			if(delta>0)
				return 4;
			if(delta<5)
				return -7;
			if(delta<5)
				return -4;
		}
		if(bpm<80) {
			if(delta<-5)
				return 7;
			if(delta<0)
				return 4;
			if(delta>5)
				return -7;
			if(delta>0)
				return -4;
		}
		if(bpm>80 && delta>0) return 1;
		if(bpm<80 && delta<0) return 1;
		if(bpm>80 && delta<0) return -1;
		if(bpm<80 && delta>0) return -1;
		return 0;
	}
	
	int maxitem(int time) {
		if(time<15) return 2;
		if(time<30) return 4;
		if(time<45) return 7;
		return 12;
	}
	
	int loweritem(int i,bool up,int lower=1,int g=0)
	{
		if(g>=2) return i;
		
		int sens=1;
		if(up) sens=-1;
		if(!lower) sens*=-1;
		sens*=-1;
		
		int delta=getdelta(i);
		if(delta==0) return i;
		int b=-1;
		for(int k=0;k<ItemEnd;k++) {
			if(1 /*|| getdelta(k)*delta>0*/) {
				if(sens*(getdelta(k))<sens*(delta)) {
					if(sens*(getdelta(k))<sens*(getdelta(b))) {
						if(g==1) {
							b=k;
						}
					} else {
						if(g==0) {
							b=k;
						}
					}
				}
			}
		}
		if(b==-1) b=i;
		debug("at %f, item lowered(up=%d,lower=%d,sens=%d,g=%d) from %d=%s (%d) to %d=%s (%d) \n",TIME(),up,lower,sens,g,i,getitemname(i).c_str(),delta,b,getitemname(b).c_str(),getdelta(b));
		return b;
	}
	
	/*
	 int seuil(int tim) {
	 if(tim<25) return 1;
	 if(tim<50) return 4;
	 if(tim<120) return 8;
	 return 9;
	 }
	 */
	
	int seuil(int tim) {
		if(tim<15) return 5;
		if(tim<60) return 8;
		return 9;
	}
	
	int minseuil(int tim) {
		if(tim<30) return -9;
		if(tim<60) return -5;
		if(tim<120) return 0;
		if(tim<180) return 3;
		return 6;
	}
	
	void senditem(int ci,int item)
	{
		int mech=ismechant(clients[ci].bpm,getdelta(item));
		debug("mechant bpm=%d delta=%d -> %d\n",clients[ci].bpm,getdelta(item),mech);
#if 0
		if(clients[ci].bpm>120 || clients[ci].bpm<70) {
			if(mech>seuil(TIME()))
				item=loweritem(item,clients[ci].bpm>80,1,TIME()<60);
			else if(mech<minseuil(TIME()))
				item=loweritem(item,clients[ci].bpm>80,0);
		}
#endif
		if(clients[ci].bpm>120 || clients[ci].bpm<70) {
			if(mech>seuil(TIME()))
				return;
		}
		debug("%d mange %d (%s)\n",ci,item,getitemname(item).c_str());
		sendmsg(ci,"mange",int2str(item));
	}
	
	
	void sendranditem(int ci)
	{
		int item=getitem(rand()%maxitem(TIME()));
		senditem(ci,item);
	}
	
	set<int> setclients;
	set<int> setclientsok;
	bool solo;
	
	game_t(const set<int> &p) {
		solo=(p.size()==1);
		setclients=p;
		setclientsok=p;
	}
	
	void sendobjs() {
		for(set<int>::iterator it=setclients.begin();it!=setclients.end();++it) {
			sendobj(*it,rand()%2);
		}
	}
	
	void readclients() {
		set<int> deads;
		for(set<int>::iterator it=setclients.begin();it!=setclients.end();++it) {
			int i=*it;
			lock();
			bool r=readclient(i,this);
			unlock();
			if(r==false) {
				deads.insert(i);
			}
		}
		if(deads.size()) {
			for(set<int>::iterator it=deads.begin();it!=deads.end();++it) {
				int i=*it;
				lock();
				setclients.erase(i);
				setclientsok.erase(i);
				unlock();
				removeclient(i);
			}
		}
	}
	
	void bcastexcept(int ic,const string &s, const string &v="1",const string &s2="",const string &v2="")
	{
		for(set<int>::iterator it=setclients.begin();it!=setclients.end();++it)
			if(*it!=ic) {
				sendmsg(*it,s,v,s2,v2);
			}
	}
	
	void bcastitemexcept(int ic,int item)
	{
		for(set<int>::iterator it=setclients.begin();it!=setclients.end();++it)
			if(*it!=ic) {
				senditem(*it,item);
			}
	}
	
	void gamemain()
	{
		debug("start game\n");
		
		TIME_START();
		
		double nextobj=8.;
		
		lock();
		for(set<int>::iterator it=setclients.begin();it!=setclients.end();++it) {
			int i=*it;
			sendstart(i);
			clients[i].setbpm(80);
			for(set<int>::iterator it2=setclients.begin();it2!=setclients.end();++it2)
				if(it!=it2) {
					sendmsg(*it,"rival",clients[*it2].name,"id",int2str(*it2));
				}
		}
		unlock();
		
		while(1) {
			lock();
			// tue les clients morts.
			
			/*
			 for(set<int>::iterator it=setclientsok.begin();it!=setclientsok.end();++it) {
			 int i=*it;
			 if(clients[i].bpm>220 || clients[i].bpm<50) {
			 sendend(i,0);
			 setclientsok.erase(i);
			 }
			 }
			 */
			
			//fin partie ?
			if(setclientsok.size()<1
			   || (solo==0 && setclientsok.size()<=1 )
			   ) {
				for(set<int>::iterator it=setclients.begin();it!=setclients.end();++it) {
					int i=*it;
					if(setclientsok.find(i)!=setclientsok.end()) {
						sendend(*(setclientsok.begin()),1);
					}
				}
				unlock();
				return;
			}
			
			unlock();
			
			//MAJ BPM
			/*
			 lock();
			 for(set<int>::iterator it=setclients.begin();it!=setclients.end();++it) {
			 int i=*it;
			 if(clients[i].changebpm) {
			 sendbpm(i,clients[i].bpm);
			 clients[i].changebpm=0;
			 }
			 }
			 unlock();
			 */
			
			//READ CLIENTS
			
			readclients();
			//unlock();
			
			debug("time : %f  \r",TIME());
			
			//AJOUT OBJ
			if(TIME()>nextobj) {
				lock();
				
#if 0
				if(solo==1) {
					sendranditem(*(players.begin()));
				}
#endif
				
				//sendobjs();
				
				if(TIME()<=32) {
					nextobj+=4;
				} else if(TIME()<64) {
					nextobj+=2;
				} else {
					nextobj+=1;
				}
				unlock();
			}
			
			usleep(10000);
		}
		
	}
};

bool process(int ic, const string &s, game_t *g)
{
	debug("process form %d '%s'\n",ic,s.c_str());
	
	Json::Value root;
	Json::Reader reader;
	bool parsingSuccessful = reader.parse( s, root );
	if ( !parsingSuccessful ) {
		std::cout  << "Failed to parse configuration\n"
		<< reader.getFormattedErrorMessages();
		return false;
	}
	
	if(g) {
		string getobj = root.get("faitmanger", "" ).asString();
		if(getobj!="") {
			g->bcastitemexcept(ic,atoi(getobj.c_str()));
			/*
			 if(getobj=="join")
			 clients[1-ic].bpm-=10;
			 if(getobj=="exta")
			 clients[1-ic].bpm+=10;
			 clients[1-ic].changebpm=1;
			 */
		}
		
		getobj = root.get("mybpm", "" ).asString();
		if(getobj!="") {
			clients[ic].bpm=atoi(getobj.c_str());
			//debug("mybpm : %s\n",getobj.c_str());
			g->bcastexcept(ic,"bpm",getobj,"id",int2str(ic));
		}
		
		getobj = root.get("jauge", "" ).asString();
		if(getobj!="") {
			g->bcastexcept(ic,"jauge",getobj,"id",int2str(ic));
		}
	}
	
	if(""!=root.get("ready", "" ).asString())  {
		//debug("%d is ready\n",ic);
		clients[ic].ready=true;
	}
	
	if(""!=root.get("bye", "" ).asString())
		return false;
	
	if(""!=root.get("ilost", "" ).asString())
		return false;
	
	return true;
}


bool readclient(int i,game_t *g) {
	char bs[1000];
	int n=read(clients[i].fd,bs,999);
	if(n>0) {
		bs[n]=0;
		char *p=bs;
		char *p2=strstr(p,"\n\n");
		while(p2) {
			*p2=0;
			int r=process(i,p,g);
			if(r==false) return false;
			p=p2+2;
			p2=0;
			if(p[0])
				p2=strstr(p,"\n\n");
		}
		if(p[0]!=0) {
			int r=process(i,p,g);
			if(r==false) return false;
		}
	} else {
		if(n==-1 && errno==EAGAIN) {
			debug("%d dit rien \r",i);
		}  else {
			log("n=%d errno=%d \n",n,errno);
			if(n==-1) perror("read");
			return false;
		}
	}
	return true;
}

void *launchgame(void *_)
{
	game_t *g=(game_t*)_;
	
	log("start game (%p) with %d players : \n",g,int(g->setclients.size()));
	for(set<int>::iterator it=g->setclients.begin();it!=g->setclients.end();++it) {
		log("%d: %s, ",*it,clients[*it].name.c_str());
	}
	log("\n");
	
	g->gamemain();
	
	log("end game %p\n",g);
	closeall(g->setclients);
	return NULL;
}


void* gameserv(void *) {
	
	while(1) {
		int ok=0;
		set<int> pp;
		set<int> deads;
		for(map<int,client_t>::iterator it=clients.begin();it!=clients.end();it++) {
			if(players.find(it->first)==players.end()) {
				int i=it->first;
				int r=readclient(i);
				if(r==false) {
					deads.insert(i);
				} else {
					pp.insert(i);
					if(clients[i].ready) ok++;
				}
			}
		}
		
		if(deads.size()) {
			for(set<int>::iterator it=deads.begin();it!=deads.end();++it)
				removeclient(*it);
			updatewaitplayers();
		}
		
		//printf("pp.size=%d ok=%d\n",int(pp.size()),ok);
		
		if(pp.size()<2 && ok==0) {
			debug("wait... (%d/%d) \r",ok,int(pp.size()));
			usleep(100000);
			continue;
		}
		
		sleep(1);
		
		lock();
		game_t *g=new game_t(pp);;
		for(set<int>::iterator it=pp.begin();it!=pp.end();++it)
			players.insert(*it);
		unlock();
		
		pthread_create(&(g->th),NULL,launchgame,g);
		//launchgame.gamemain();
	}
	
	return NULL;
}

int main()
{
	srand(time(NULL));
	
	pthread_t thserv;
	pthread_create(&thserv,NULL,tcpserv,NULL);
	
	pthread_t thgame;
	pthread_create(&thgame,NULL,gameserv,NULL);
	
	pthread_join(thserv,NULL);
	pthread_join(thgame,NULL);
	
	return 0;
}
