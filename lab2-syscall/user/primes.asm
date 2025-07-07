
user/_primes:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <prime>:
#include "kernel/stat.h"
#include "user/user.h"
# define MAXSIZE 35
const int one = 1;
const int zero = 0;
void prime(int pipe_read){
   0:	7131                	addi	sp,sp,-192
   2:	fd06                	sd	ra,184(sp)
   4:	f922                	sd	s0,176(sp)
   6:	f526                	sd	s1,168(sp)
   8:	f14a                	sd	s2,160(sp)
   a:	0180                	addi	s0,sp,192
   c:	892a                	mv	s2,a0
    int prime_value = 0;
    int num[MAXSIZE];

    // 正确的读取整个数组
    if(read(pipe_read, num, sizeof(num)) <= 0){
   e:	08c00613          	li	a2,140
  12:	f5040593          	addi	a1,s0,-176
  16:	00000097          	auipc	ra,0x0
  1a:	498080e7          	jalr	1176(ra) # 4ae <read>
  1e:	f5840793          	addi	a5,s0,-168
        close(pipe_read);
        exit(0);
    }

    for(int i = 2; i < MAXSIZE; ++i){
  22:	4489                	li	s1,2
        if(num[i] == one){
  24:	4685                	li	a3,1
    for(int i = 2; i < MAXSIZE; ++i){
  26:	02300613          	li	a2,35
    if(read(pipe_read, num, sizeof(num)) <= 0){
  2a:	02a05363          	blez	a0,50 <prime+0x50>
        if(num[i] == one){
  2e:	4398                	lw	a4,0(a5)
  30:	02d70a63          	beq	a4,a3,64 <prime+0x64>
    for(int i = 2; i < MAXSIZE; ++i){
  34:	2485                	addiw	s1,s1,1
  36:	0791                	addi	a5,a5,4
  38:	fec49be3          	bne	s1,a2,2e <prime+0x2e>
            prime_value = i;
            break;
        }
    }
    if (prime_value == 0) {
        close(pipe_read);
  3c:	854a                	mv	a0,s2
  3e:	00000097          	auipc	ra,0x0
  42:	480080e7          	jalr	1152(ra) # 4be <close>
        exit(0);
  46:	4501                	li	a0,0
  48:	00000097          	auipc	ra,0x0
  4c:	44e080e7          	jalr	1102(ra) # 496 <exit>
        close(pipe_read);
  50:	854a                	mv	a0,s2
  52:	00000097          	auipc	ra,0x0
  56:	46c080e7          	jalr	1132(ra) # 4be <close>
        exit(0);
  5a:	4501                	li	a0,0
  5c:	00000097          	auipc	ra,0x0
  60:	43a080e7          	jalr	1082(ra) # 496 <exit>
    if (prime_value == 0) {
  64:	dce1                	beqz	s1,3c <prime+0x3c>
    }
    printf("pid -> %d: find prime %d\n", getpid(), prime_value);
  66:	00000097          	auipc	ra,0x0
  6a:	4b0080e7          	jalr	1200(ra) # 516 <getpid>
  6e:	85aa                	mv	a1,a0
  70:	8626                	mv	a2,s1
  72:	00001517          	auipc	a0,0x1
  76:	93e50513          	addi	a0,a0,-1730 # 9b0 <malloc+0xe4>
  7a:	00000097          	auipc	ra,0x0
  7e:	794080e7          	jalr	1940(ra) # 80e <printf>

    // 创建新管道用于子进程
    int new_pipe[2];
    pipe(new_pipe);
  82:	f4840513          	addi	a0,s0,-184
  86:	00000097          	auipc	ra,0x0
  8a:	420080e7          	jalr	1056(ra) # 4a6 <pipe>

    num[prime_value] = zero;
  8e:	00249793          	slli	a5,s1,0x2
  92:	fe040713          	addi	a4,s0,-32
  96:	97ba                	add	a5,a5,a4
  98:	f607a823          	sw	zero,-144(a5)
    for(int i = prime_value; i < MAXSIZE; ++i){
  9c:	02200793          	li	a5,34
  a0:	0297c663          	blt	a5,s1,cc <prime+0xcc>
  a4:	87a6                	mv	a5,s1
  a6:	02200693          	li	a3,34
  aa:	a031                	j	b6 <prime+0xb6>
  ac:	0785                	addi	a5,a5,1
  ae:	0007871b          	sext.w	a4,a5
  b2:	00e6cd63          	blt	a3,a4,cc <prime+0xcc>
        if(i % prime_value == 0){
  b6:	0297e73b          	remw	a4,a5,s1
  ba:	fb6d                	bnez	a4,ac <prime+0xac>
            num[i] = zero;
  bc:	00279713          	slli	a4,a5,0x2
  c0:	f5040613          	addi	a2,s0,-176
  c4:	9732                	add	a4,a4,a2
  c6:	00072023          	sw	zero,0(a4)
  ca:	b7cd                	j	ac <prime+0xac>
        }
    }

    int pid = fork();
  cc:	00000097          	auipc	ra,0x0
  d0:	3c2080e7          	jalr	962(ra) # 48e <fork>
    if(pid > 0){
  d4:	00a04963          	bgtz	a0,e6 <prime+0xe6>
        // 写入处理后的数组
        write(new_pipe[1], num, sizeof(num));
        close(new_pipe[1]);
        wait(0);  // 等待子进程
    }
    if(pid == 0){
  d8:	c925                	beqz	a0,148 <prime+0x148>
        close(new_pipe[1]);  // 子进程关闭写端
        prime(new_pipe[0]);  // 递归处理
        close(new_pipe[0]);
        exit(0);
    }
}
  da:	70ea                	ld	ra,184(sp)
  dc:	744a                	ld	s0,176(sp)
  de:	74aa                	ld	s1,168(sp)
  e0:	790a                	ld	s2,160(sp)
  e2:	6129                	addi	sp,sp,192
  e4:	8082                	ret
        close(new_pipe[0]);  // 父进程关闭读端
  e6:	f4842503          	lw	a0,-184(s0)
  ea:	00000097          	auipc	ra,0x0
  ee:	3d4080e7          	jalr	980(ra) # 4be <close>
        for (int i = prime_value * 2; i < MAXSIZE; i += prime_value) {
  f2:	0014979b          	slliw	a5,s1,0x1
  f6:	02200713          	li	a4,34
  fa:	02f74163          	blt	a4,a5,11c <prime+0x11c>
  fe:	00249613          	slli	a2,s1,0x2
 102:	00279713          	slli	a4,a5,0x2
 106:	f5040693          	addi	a3,s0,-176
 10a:	9736                	add	a4,a4,a3
 10c:	02200693          	li	a3,34
            num[i] = zero;
 110:	00072023          	sw	zero,0(a4)
        for (int i = prime_value * 2; i < MAXSIZE; i += prime_value) {
 114:	9fa5                	addw	a5,a5,s1
 116:	9732                	add	a4,a4,a2
 118:	fef6dce3          	bge	a3,a5,110 <prime+0x110>
        write(new_pipe[1], num, sizeof(num));
 11c:	08c00613          	li	a2,140
 120:	f5040593          	addi	a1,s0,-176
 124:	f4c42503          	lw	a0,-180(s0)
 128:	00000097          	auipc	ra,0x0
 12c:	38e080e7          	jalr	910(ra) # 4b6 <write>
        close(new_pipe[1]);
 130:	f4c42503          	lw	a0,-180(s0)
 134:	00000097          	auipc	ra,0x0
 138:	38a080e7          	jalr	906(ra) # 4be <close>
        wait(0);  // 等待子进程
 13c:	4501                	li	a0,0
 13e:	00000097          	auipc	ra,0x0
 142:	360080e7          	jalr	864(ra) # 49e <wait>
    if(pid == 0){
 146:	bf51                	j	da <prime+0xda>
        close(new_pipe[1]);  // 子进程关闭写端
 148:	f4c42503          	lw	a0,-180(s0)
 14c:	00000097          	auipc	ra,0x0
 150:	372080e7          	jalr	882(ra) # 4be <close>
        prime(new_pipe[0]);  // 递归处理
 154:	f4842503          	lw	a0,-184(s0)
 158:	00000097          	auipc	ra,0x0
 15c:	ea8080e7          	jalr	-344(ra) # 0 <prime>
        close(new_pipe[0]);
 160:	f4842503          	lw	a0,-184(s0)
 164:	00000097          	auipc	ra,0x0
 168:	35a080e7          	jalr	858(ra) # 4be <close>
        exit(0);
 16c:	4501                	li	a0,0
 16e:	00000097          	auipc	ra,0x0
 172:	328080e7          	jalr	808(ra) # 496 <exit>

0000000000000176 <main>:

int main(int argc, char**argv){
 176:	7171                	addi	sp,sp,-176
 178:	f506                	sd	ra,168(sp)
 17a:	f122                	sd	s0,160(sp)
 17c:	1900                	addi	s0,sp,176
    int num[MAXSIZE];
    for(int i = 0; i < MAXSIZE; ++i){
 17e:	f6040793          	addi	a5,s0,-160
 182:	fec40693          	addi	a3,s0,-20
        num[i] = one;
 186:	4705                	li	a4,1
 188:	c398                	sw	a4,0(a5)
    for(int i = 0; i < MAXSIZE; ++i){
 18a:	0791                	addi	a5,a5,4
 18c:	fed79ee3          	bne	a5,a3,188 <main+0x12>
    }
    num[0] = zero;
 190:	f6042023          	sw	zero,-160(s0)
    num[1] = zero;
 194:	f6042223          	sw	zero,-156(s0)

    int p[2];
    pipe(p);
 198:	f5840513          	addi	a0,s0,-168
 19c:	00000097          	auipc	ra,0x0
 1a0:	30a080e7          	jalr	778(ra) # 4a6 <pipe>
    int pid = fork();
 1a4:	00000097          	auipc	ra,0x0
 1a8:	2ea080e7          	jalr	746(ra) # 48e <fork>
    if(pid > 0){
 1ac:	02a04a63          	bgtz	a0,1e0 <main+0x6a>
        close(p[0]);  // 父进程关闭读端
        write(p[1], num, sizeof(num));  // 写入初始数组
        close(p[1]);
        wait(0);  // 等待子进程链结束
    }
    if(pid == 0){
 1b0:	e13d                	bnez	a0,216 <main+0xa0>
        close(p[1]);  // 子进程关闭写端
 1b2:	f5c42503          	lw	a0,-164(s0)
 1b6:	00000097          	auipc	ra,0x0
 1ba:	308080e7          	jalr	776(ra) # 4be <close>
        prime(p[0]);   // 开始筛选
 1be:	f5842503          	lw	a0,-168(s0)
 1c2:	00000097          	auipc	ra,0x0
 1c6:	e3e080e7          	jalr	-450(ra) # 0 <prime>
        close(p[0]);
 1ca:	f5842503          	lw	a0,-168(s0)
 1ce:	00000097          	auipc	ra,0x0
 1d2:	2f0080e7          	jalr	752(ra) # 4be <close>
        exit(0);
 1d6:	4501                	li	a0,0
 1d8:	00000097          	auipc	ra,0x0
 1dc:	2be080e7          	jalr	702(ra) # 496 <exit>
        close(p[0]);  // 父进程关闭读端
 1e0:	f5842503          	lw	a0,-168(s0)
 1e4:	00000097          	auipc	ra,0x0
 1e8:	2da080e7          	jalr	730(ra) # 4be <close>
        write(p[1], num, sizeof(num));  // 写入初始数组
 1ec:	08c00613          	li	a2,140
 1f0:	f6040593          	addi	a1,s0,-160
 1f4:	f5c42503          	lw	a0,-164(s0)
 1f8:	00000097          	auipc	ra,0x0
 1fc:	2be080e7          	jalr	702(ra) # 4b6 <write>
        close(p[1]);
 200:	f5c42503          	lw	a0,-164(s0)
 204:	00000097          	auipc	ra,0x0
 208:	2ba080e7          	jalr	698(ra) # 4be <close>
        wait(0);  // 等待子进程链结束
 20c:	4501                	li	a0,0
 20e:	00000097          	auipc	ra,0x0
 212:	290080e7          	jalr	656(ra) # 49e <wait>
    }
    exit(0);
 216:	4501                	li	a0,0
 218:	00000097          	auipc	ra,0x0
 21c:	27e080e7          	jalr	638(ra) # 496 <exit>

0000000000000220 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 220:	1141                	addi	sp,sp,-16
 222:	e422                	sd	s0,8(sp)
 224:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 226:	87aa                	mv	a5,a0
 228:	0585                	addi	a1,a1,1
 22a:	0785                	addi	a5,a5,1
 22c:	fff5c703          	lbu	a4,-1(a1)
 230:	fee78fa3          	sb	a4,-1(a5)
 234:	fb75                	bnez	a4,228 <strcpy+0x8>
    ;
  return os;
}
 236:	6422                	ld	s0,8(sp)
 238:	0141                	addi	sp,sp,16
 23a:	8082                	ret

000000000000023c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 23c:	1141                	addi	sp,sp,-16
 23e:	e422                	sd	s0,8(sp)
 240:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 242:	00054783          	lbu	a5,0(a0)
 246:	cb91                	beqz	a5,25a <strcmp+0x1e>
 248:	0005c703          	lbu	a4,0(a1)
 24c:	00f71763          	bne	a4,a5,25a <strcmp+0x1e>
    p++, q++;
 250:	0505                	addi	a0,a0,1
 252:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 254:	00054783          	lbu	a5,0(a0)
 258:	fbe5                	bnez	a5,248 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 25a:	0005c503          	lbu	a0,0(a1)
}
 25e:	40a7853b          	subw	a0,a5,a0
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret

0000000000000268 <strlen>:

uint
strlen(const char *s)
{
 268:	1141                	addi	sp,sp,-16
 26a:	e422                	sd	s0,8(sp)
 26c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 26e:	00054783          	lbu	a5,0(a0)
 272:	cf91                	beqz	a5,28e <strlen+0x26>
 274:	0505                	addi	a0,a0,1
 276:	87aa                	mv	a5,a0
 278:	4685                	li	a3,1
 27a:	9e89                	subw	a3,a3,a0
 27c:	00f6853b          	addw	a0,a3,a5
 280:	0785                	addi	a5,a5,1
 282:	fff7c703          	lbu	a4,-1(a5)
 286:	fb7d                	bnez	a4,27c <strlen+0x14>
    ;
  return n;
}
 288:	6422                	ld	s0,8(sp)
 28a:	0141                	addi	sp,sp,16
 28c:	8082                	ret
  for(n = 0; s[n]; n++)
 28e:	4501                	li	a0,0
 290:	bfe5                	j	288 <strlen+0x20>

0000000000000292 <memset>:

void*
memset(void *dst, int c, uint n)
{
 292:	1141                	addi	sp,sp,-16
 294:	e422                	sd	s0,8(sp)
 296:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 298:	ce09                	beqz	a2,2b2 <memset+0x20>
 29a:	87aa                	mv	a5,a0
 29c:	fff6071b          	addiw	a4,a2,-1
 2a0:	1702                	slli	a4,a4,0x20
 2a2:	9301                	srli	a4,a4,0x20
 2a4:	0705                	addi	a4,a4,1
 2a6:	972a                	add	a4,a4,a0
    cdst[i] = c;
 2a8:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2ac:	0785                	addi	a5,a5,1
 2ae:	fee79de3          	bne	a5,a4,2a8 <memset+0x16>
  }
  return dst;
}
 2b2:	6422                	ld	s0,8(sp)
 2b4:	0141                	addi	sp,sp,16
 2b6:	8082                	ret

00000000000002b8 <strchr>:

char*
strchr(const char *s, char c)
{
 2b8:	1141                	addi	sp,sp,-16
 2ba:	e422                	sd	s0,8(sp)
 2bc:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2be:	00054783          	lbu	a5,0(a0)
 2c2:	cb99                	beqz	a5,2d8 <strchr+0x20>
    if(*s == c)
 2c4:	00f58763          	beq	a1,a5,2d2 <strchr+0x1a>
  for(; *s; s++)
 2c8:	0505                	addi	a0,a0,1
 2ca:	00054783          	lbu	a5,0(a0)
 2ce:	fbfd                	bnez	a5,2c4 <strchr+0xc>
      return (char*)s;
  return 0;
 2d0:	4501                	li	a0,0
}
 2d2:	6422                	ld	s0,8(sp)
 2d4:	0141                	addi	sp,sp,16
 2d6:	8082                	ret
  return 0;
 2d8:	4501                	li	a0,0
 2da:	bfe5                	j	2d2 <strchr+0x1a>

00000000000002dc <gets>:

char*
gets(char *buf, int max)
{
 2dc:	711d                	addi	sp,sp,-96
 2de:	ec86                	sd	ra,88(sp)
 2e0:	e8a2                	sd	s0,80(sp)
 2e2:	e4a6                	sd	s1,72(sp)
 2e4:	e0ca                	sd	s2,64(sp)
 2e6:	fc4e                	sd	s3,56(sp)
 2e8:	f852                	sd	s4,48(sp)
 2ea:	f456                	sd	s5,40(sp)
 2ec:	f05a                	sd	s6,32(sp)
 2ee:	ec5e                	sd	s7,24(sp)
 2f0:	1080                	addi	s0,sp,96
 2f2:	8baa                	mv	s7,a0
 2f4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2f6:	892a                	mv	s2,a0
 2f8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2fa:	4aa9                	li	s5,10
 2fc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2fe:	89a6                	mv	s3,s1
 300:	2485                	addiw	s1,s1,1
 302:	0344d863          	bge	s1,s4,332 <gets+0x56>
    cc = read(0, &c, 1);
 306:	4605                	li	a2,1
 308:	faf40593          	addi	a1,s0,-81
 30c:	4501                	li	a0,0
 30e:	00000097          	auipc	ra,0x0
 312:	1a0080e7          	jalr	416(ra) # 4ae <read>
    if(cc < 1)
 316:	00a05e63          	blez	a0,332 <gets+0x56>
    buf[i++] = c;
 31a:	faf44783          	lbu	a5,-81(s0)
 31e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 322:	01578763          	beq	a5,s5,330 <gets+0x54>
 326:	0905                	addi	s2,s2,1
 328:	fd679be3          	bne	a5,s6,2fe <gets+0x22>
  for(i=0; i+1 < max; ){
 32c:	89a6                	mv	s3,s1
 32e:	a011                	j	332 <gets+0x56>
 330:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 332:	99de                	add	s3,s3,s7
 334:	00098023          	sb	zero,0(s3)
  return buf;
}
 338:	855e                	mv	a0,s7
 33a:	60e6                	ld	ra,88(sp)
 33c:	6446                	ld	s0,80(sp)
 33e:	64a6                	ld	s1,72(sp)
 340:	6906                	ld	s2,64(sp)
 342:	79e2                	ld	s3,56(sp)
 344:	7a42                	ld	s4,48(sp)
 346:	7aa2                	ld	s5,40(sp)
 348:	7b02                	ld	s6,32(sp)
 34a:	6be2                	ld	s7,24(sp)
 34c:	6125                	addi	sp,sp,96
 34e:	8082                	ret

0000000000000350 <stat>:

int
stat(const char *n, struct stat *st)
{
 350:	1101                	addi	sp,sp,-32
 352:	ec06                	sd	ra,24(sp)
 354:	e822                	sd	s0,16(sp)
 356:	e426                	sd	s1,8(sp)
 358:	e04a                	sd	s2,0(sp)
 35a:	1000                	addi	s0,sp,32
 35c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 35e:	4581                	li	a1,0
 360:	00000097          	auipc	ra,0x0
 364:	176080e7          	jalr	374(ra) # 4d6 <open>
  if(fd < 0)
 368:	02054563          	bltz	a0,392 <stat+0x42>
 36c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 36e:	85ca                	mv	a1,s2
 370:	00000097          	auipc	ra,0x0
 374:	17e080e7          	jalr	382(ra) # 4ee <fstat>
 378:	892a                	mv	s2,a0
  close(fd);
 37a:	8526                	mv	a0,s1
 37c:	00000097          	auipc	ra,0x0
 380:	142080e7          	jalr	322(ra) # 4be <close>
  return r;
}
 384:	854a                	mv	a0,s2
 386:	60e2                	ld	ra,24(sp)
 388:	6442                	ld	s0,16(sp)
 38a:	64a2                	ld	s1,8(sp)
 38c:	6902                	ld	s2,0(sp)
 38e:	6105                	addi	sp,sp,32
 390:	8082                	ret
    return -1;
 392:	597d                	li	s2,-1
 394:	bfc5                	j	384 <stat+0x34>

0000000000000396 <atoi>:

int
atoi(const char *s)
{
 396:	1141                	addi	sp,sp,-16
 398:	e422                	sd	s0,8(sp)
 39a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 39c:	00054603          	lbu	a2,0(a0)
 3a0:	fd06079b          	addiw	a5,a2,-48
 3a4:	0ff7f793          	andi	a5,a5,255
 3a8:	4725                	li	a4,9
 3aa:	02f76963          	bltu	a4,a5,3dc <atoi+0x46>
 3ae:	86aa                	mv	a3,a0
  n = 0;
 3b0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3b2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3b4:	0685                	addi	a3,a3,1
 3b6:	0025179b          	slliw	a5,a0,0x2
 3ba:	9fa9                	addw	a5,a5,a0
 3bc:	0017979b          	slliw	a5,a5,0x1
 3c0:	9fb1                	addw	a5,a5,a2
 3c2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3c6:	0006c603          	lbu	a2,0(a3)
 3ca:	fd06071b          	addiw	a4,a2,-48
 3ce:	0ff77713          	andi	a4,a4,255
 3d2:	fee5f1e3          	bgeu	a1,a4,3b4 <atoi+0x1e>
  return n;
}
 3d6:	6422                	ld	s0,8(sp)
 3d8:	0141                	addi	sp,sp,16
 3da:	8082                	ret
  n = 0;
 3dc:	4501                	li	a0,0
 3de:	bfe5                	j	3d6 <atoi+0x40>

00000000000003e0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3e0:	1141                	addi	sp,sp,-16
 3e2:	e422                	sd	s0,8(sp)
 3e4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3e6:	02b57663          	bgeu	a0,a1,412 <memmove+0x32>
    while(n-- > 0)
 3ea:	02c05163          	blez	a2,40c <memmove+0x2c>
 3ee:	fff6079b          	addiw	a5,a2,-1
 3f2:	1782                	slli	a5,a5,0x20
 3f4:	9381                	srli	a5,a5,0x20
 3f6:	0785                	addi	a5,a5,1
 3f8:	97aa                	add	a5,a5,a0
  dst = vdst;
 3fa:	872a                	mv	a4,a0
      *dst++ = *src++;
 3fc:	0585                	addi	a1,a1,1
 3fe:	0705                	addi	a4,a4,1
 400:	fff5c683          	lbu	a3,-1(a1)
 404:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 408:	fee79ae3          	bne	a5,a4,3fc <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 40c:	6422                	ld	s0,8(sp)
 40e:	0141                	addi	sp,sp,16
 410:	8082                	ret
    dst += n;
 412:	00c50733          	add	a4,a0,a2
    src += n;
 416:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 418:	fec05ae3          	blez	a2,40c <memmove+0x2c>
 41c:	fff6079b          	addiw	a5,a2,-1
 420:	1782                	slli	a5,a5,0x20
 422:	9381                	srli	a5,a5,0x20
 424:	fff7c793          	not	a5,a5
 428:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 42a:	15fd                	addi	a1,a1,-1
 42c:	177d                	addi	a4,a4,-1
 42e:	0005c683          	lbu	a3,0(a1)
 432:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 436:	fee79ae3          	bne	a5,a4,42a <memmove+0x4a>
 43a:	bfc9                	j	40c <memmove+0x2c>

000000000000043c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 43c:	1141                	addi	sp,sp,-16
 43e:	e422                	sd	s0,8(sp)
 440:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 442:	ca05                	beqz	a2,472 <memcmp+0x36>
 444:	fff6069b          	addiw	a3,a2,-1
 448:	1682                	slli	a3,a3,0x20
 44a:	9281                	srli	a3,a3,0x20
 44c:	0685                	addi	a3,a3,1
 44e:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 450:	00054783          	lbu	a5,0(a0)
 454:	0005c703          	lbu	a4,0(a1)
 458:	00e79863          	bne	a5,a4,468 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 45c:	0505                	addi	a0,a0,1
    p2++;
 45e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 460:	fed518e3          	bne	a0,a3,450 <memcmp+0x14>
  }
  return 0;
 464:	4501                	li	a0,0
 466:	a019                	j	46c <memcmp+0x30>
      return *p1 - *p2;
 468:	40e7853b          	subw	a0,a5,a4
}
 46c:	6422                	ld	s0,8(sp)
 46e:	0141                	addi	sp,sp,16
 470:	8082                	ret
  return 0;
 472:	4501                	li	a0,0
 474:	bfe5                	j	46c <memcmp+0x30>

0000000000000476 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 476:	1141                	addi	sp,sp,-16
 478:	e406                	sd	ra,8(sp)
 47a:	e022                	sd	s0,0(sp)
 47c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 47e:	00000097          	auipc	ra,0x0
 482:	f62080e7          	jalr	-158(ra) # 3e0 <memmove>
}
 486:	60a2                	ld	ra,8(sp)
 488:	6402                	ld	s0,0(sp)
 48a:	0141                	addi	sp,sp,16
 48c:	8082                	ret

000000000000048e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 48e:	4885                	li	a7,1
 ecall
 490:	00000073          	ecall
 ret
 494:	8082                	ret

0000000000000496 <exit>:
.global exit
exit:
 li a7, SYS_exit
 496:	4889                	li	a7,2
 ecall
 498:	00000073          	ecall
 ret
 49c:	8082                	ret

000000000000049e <wait>:
.global wait
wait:
 li a7, SYS_wait
 49e:	488d                	li	a7,3
 ecall
 4a0:	00000073          	ecall
 ret
 4a4:	8082                	ret

00000000000004a6 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 4a6:	4891                	li	a7,4
 ecall
 4a8:	00000073          	ecall
 ret
 4ac:	8082                	ret

00000000000004ae <read>:
.global read
read:
 li a7, SYS_read
 4ae:	4895                	li	a7,5
 ecall
 4b0:	00000073          	ecall
 ret
 4b4:	8082                	ret

00000000000004b6 <write>:
.global write
write:
 li a7, SYS_write
 4b6:	48c1                	li	a7,16
 ecall
 4b8:	00000073          	ecall
 ret
 4bc:	8082                	ret

00000000000004be <close>:
.global close
close:
 li a7, SYS_close
 4be:	48d5                	li	a7,21
 ecall
 4c0:	00000073          	ecall
 ret
 4c4:	8082                	ret

00000000000004c6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 4c6:	4899                	li	a7,6
 ecall
 4c8:	00000073          	ecall
 ret
 4cc:	8082                	ret

00000000000004ce <exec>:
.global exec
exec:
 li a7, SYS_exec
 4ce:	489d                	li	a7,7
 ecall
 4d0:	00000073          	ecall
 ret
 4d4:	8082                	ret

00000000000004d6 <open>:
.global open
open:
 li a7, SYS_open
 4d6:	48bd                	li	a7,15
 ecall
 4d8:	00000073          	ecall
 ret
 4dc:	8082                	ret

00000000000004de <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4de:	48c5                	li	a7,17
 ecall
 4e0:	00000073          	ecall
 ret
 4e4:	8082                	ret

00000000000004e6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4e6:	48c9                	li	a7,18
 ecall
 4e8:	00000073          	ecall
 ret
 4ec:	8082                	ret

00000000000004ee <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4ee:	48a1                	li	a7,8
 ecall
 4f0:	00000073          	ecall
 ret
 4f4:	8082                	ret

00000000000004f6 <link>:
.global link
link:
 li a7, SYS_link
 4f6:	48cd                	li	a7,19
 ecall
 4f8:	00000073          	ecall
 ret
 4fc:	8082                	ret

00000000000004fe <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4fe:	48d1                	li	a7,20
 ecall
 500:	00000073          	ecall
 ret
 504:	8082                	ret

0000000000000506 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 506:	48a5                	li	a7,9
 ecall
 508:	00000073          	ecall
 ret
 50c:	8082                	ret

000000000000050e <dup>:
.global dup
dup:
 li a7, SYS_dup
 50e:	48a9                	li	a7,10
 ecall
 510:	00000073          	ecall
 ret
 514:	8082                	ret

0000000000000516 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 516:	48ad                	li	a7,11
 ecall
 518:	00000073          	ecall
 ret
 51c:	8082                	ret

000000000000051e <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 51e:	48b1                	li	a7,12
 ecall
 520:	00000073          	ecall
 ret
 524:	8082                	ret

0000000000000526 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 526:	48b5                	li	a7,13
 ecall
 528:	00000073          	ecall
 ret
 52c:	8082                	ret

000000000000052e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 52e:	48b9                	li	a7,14
 ecall
 530:	00000073          	ecall
 ret
 534:	8082                	ret

0000000000000536 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 536:	1101                	addi	sp,sp,-32
 538:	ec06                	sd	ra,24(sp)
 53a:	e822                	sd	s0,16(sp)
 53c:	1000                	addi	s0,sp,32
 53e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 542:	4605                	li	a2,1
 544:	fef40593          	addi	a1,s0,-17
 548:	00000097          	auipc	ra,0x0
 54c:	f6e080e7          	jalr	-146(ra) # 4b6 <write>
}
 550:	60e2                	ld	ra,24(sp)
 552:	6442                	ld	s0,16(sp)
 554:	6105                	addi	sp,sp,32
 556:	8082                	ret

0000000000000558 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 558:	7139                	addi	sp,sp,-64
 55a:	fc06                	sd	ra,56(sp)
 55c:	f822                	sd	s0,48(sp)
 55e:	f426                	sd	s1,40(sp)
 560:	f04a                	sd	s2,32(sp)
 562:	ec4e                	sd	s3,24(sp)
 564:	0080                	addi	s0,sp,64
 566:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 568:	c299                	beqz	a3,56e <printint+0x16>
 56a:	0805c863          	bltz	a1,5fa <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 56e:	2581                	sext.w	a1,a1
  neg = 0;
 570:	4881                	li	a7,0
 572:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 576:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 578:	2601                	sext.w	a2,a2
 57a:	00000517          	auipc	a0,0x0
 57e:	45e50513          	addi	a0,a0,1118 # 9d8 <digits>
 582:	883a                	mv	a6,a4
 584:	2705                	addiw	a4,a4,1
 586:	02c5f7bb          	remuw	a5,a1,a2
 58a:	1782                	slli	a5,a5,0x20
 58c:	9381                	srli	a5,a5,0x20
 58e:	97aa                	add	a5,a5,a0
 590:	0007c783          	lbu	a5,0(a5)
 594:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 598:	0005879b          	sext.w	a5,a1
 59c:	02c5d5bb          	divuw	a1,a1,a2
 5a0:	0685                	addi	a3,a3,1
 5a2:	fec7f0e3          	bgeu	a5,a2,582 <printint+0x2a>
  if(neg)
 5a6:	00088b63          	beqz	a7,5bc <printint+0x64>
    buf[i++] = '-';
 5aa:	fd040793          	addi	a5,s0,-48
 5ae:	973e                	add	a4,a4,a5
 5b0:	02d00793          	li	a5,45
 5b4:	fef70823          	sb	a5,-16(a4)
 5b8:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5bc:	02e05863          	blez	a4,5ec <printint+0x94>
 5c0:	fc040793          	addi	a5,s0,-64
 5c4:	00e78933          	add	s2,a5,a4
 5c8:	fff78993          	addi	s3,a5,-1
 5cc:	99ba                	add	s3,s3,a4
 5ce:	377d                	addiw	a4,a4,-1
 5d0:	1702                	slli	a4,a4,0x20
 5d2:	9301                	srli	a4,a4,0x20
 5d4:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5d8:	fff94583          	lbu	a1,-1(s2)
 5dc:	8526                	mv	a0,s1
 5de:	00000097          	auipc	ra,0x0
 5e2:	f58080e7          	jalr	-168(ra) # 536 <putc>
  while(--i >= 0)
 5e6:	197d                	addi	s2,s2,-1
 5e8:	ff3918e3          	bne	s2,s3,5d8 <printint+0x80>
}
 5ec:	70e2                	ld	ra,56(sp)
 5ee:	7442                	ld	s0,48(sp)
 5f0:	74a2                	ld	s1,40(sp)
 5f2:	7902                	ld	s2,32(sp)
 5f4:	69e2                	ld	s3,24(sp)
 5f6:	6121                	addi	sp,sp,64
 5f8:	8082                	ret
    x = -xx;
 5fa:	40b005bb          	negw	a1,a1
    neg = 1;
 5fe:	4885                	li	a7,1
    x = -xx;
 600:	bf8d                	j	572 <printint+0x1a>

0000000000000602 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 602:	7119                	addi	sp,sp,-128
 604:	fc86                	sd	ra,120(sp)
 606:	f8a2                	sd	s0,112(sp)
 608:	f4a6                	sd	s1,104(sp)
 60a:	f0ca                	sd	s2,96(sp)
 60c:	ecce                	sd	s3,88(sp)
 60e:	e8d2                	sd	s4,80(sp)
 610:	e4d6                	sd	s5,72(sp)
 612:	e0da                	sd	s6,64(sp)
 614:	fc5e                	sd	s7,56(sp)
 616:	f862                	sd	s8,48(sp)
 618:	f466                	sd	s9,40(sp)
 61a:	f06a                	sd	s10,32(sp)
 61c:	ec6e                	sd	s11,24(sp)
 61e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 620:	0005c903          	lbu	s2,0(a1)
 624:	18090f63          	beqz	s2,7c2 <vprintf+0x1c0>
 628:	8aaa                	mv	s5,a0
 62a:	8b32                	mv	s6,a2
 62c:	00158493          	addi	s1,a1,1
  state = 0;
 630:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 632:	02500a13          	li	s4,37
      if(c == 'd'){
 636:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 63a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 63e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 642:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 646:	00000b97          	auipc	s7,0x0
 64a:	392b8b93          	addi	s7,s7,914 # 9d8 <digits>
 64e:	a839                	j	66c <vprintf+0x6a>
        putc(fd, c);
 650:	85ca                	mv	a1,s2
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	ee2080e7          	jalr	-286(ra) # 536 <putc>
 65c:	a019                	j	662 <vprintf+0x60>
    } else if(state == '%'){
 65e:	01498f63          	beq	s3,s4,67c <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 662:	0485                	addi	s1,s1,1
 664:	fff4c903          	lbu	s2,-1(s1)
 668:	14090d63          	beqz	s2,7c2 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 66c:	0009079b          	sext.w	a5,s2
    if(state == 0){
 670:	fe0997e3          	bnez	s3,65e <vprintf+0x5c>
      if(c == '%'){
 674:	fd479ee3          	bne	a5,s4,650 <vprintf+0x4e>
        state = '%';
 678:	89be                	mv	s3,a5
 67a:	b7e5                	j	662 <vprintf+0x60>
      if(c == 'd'){
 67c:	05878063          	beq	a5,s8,6bc <vprintf+0xba>
      } else if(c == 'l') {
 680:	05978c63          	beq	a5,s9,6d8 <vprintf+0xd6>
      } else if(c == 'x') {
 684:	07a78863          	beq	a5,s10,6f4 <vprintf+0xf2>
      } else if(c == 'p') {
 688:	09b78463          	beq	a5,s11,710 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 68c:	07300713          	li	a4,115
 690:	0ce78663          	beq	a5,a4,75c <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 694:	06300713          	li	a4,99
 698:	0ee78e63          	beq	a5,a4,794 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 69c:	11478863          	beq	a5,s4,7ac <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 6a0:	85d2                	mv	a1,s4
 6a2:	8556                	mv	a0,s5
 6a4:	00000097          	auipc	ra,0x0
 6a8:	e92080e7          	jalr	-366(ra) # 536 <putc>
        putc(fd, c);
 6ac:	85ca                	mv	a1,s2
 6ae:	8556                	mv	a0,s5
 6b0:	00000097          	auipc	ra,0x0
 6b4:	e86080e7          	jalr	-378(ra) # 536 <putc>
      }
      state = 0;
 6b8:	4981                	li	s3,0
 6ba:	b765                	j	662 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6bc:	008b0913          	addi	s2,s6,8
 6c0:	4685                	li	a3,1
 6c2:	4629                	li	a2,10
 6c4:	000b2583          	lw	a1,0(s6)
 6c8:	8556                	mv	a0,s5
 6ca:	00000097          	auipc	ra,0x0
 6ce:	e8e080e7          	jalr	-370(ra) # 558 <printint>
 6d2:	8b4a                	mv	s6,s2
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b771                	j	662 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6d8:	008b0913          	addi	s2,s6,8
 6dc:	4681                	li	a3,0
 6de:	4629                	li	a2,10
 6e0:	000b2583          	lw	a1,0(s6)
 6e4:	8556                	mv	a0,s5
 6e6:	00000097          	auipc	ra,0x0
 6ea:	e72080e7          	jalr	-398(ra) # 558 <printint>
 6ee:	8b4a                	mv	s6,s2
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	bf85                	j	662 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6f4:	008b0913          	addi	s2,s6,8
 6f8:	4681                	li	a3,0
 6fa:	4641                	li	a2,16
 6fc:	000b2583          	lw	a1,0(s6)
 700:	8556                	mv	a0,s5
 702:	00000097          	auipc	ra,0x0
 706:	e56080e7          	jalr	-426(ra) # 558 <printint>
 70a:	8b4a                	mv	s6,s2
      state = 0;
 70c:	4981                	li	s3,0
 70e:	bf91                	j	662 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 710:	008b0793          	addi	a5,s6,8
 714:	f8f43423          	sd	a5,-120(s0)
 718:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 71c:	03000593          	li	a1,48
 720:	8556                	mv	a0,s5
 722:	00000097          	auipc	ra,0x0
 726:	e14080e7          	jalr	-492(ra) # 536 <putc>
  putc(fd, 'x');
 72a:	85ea                	mv	a1,s10
 72c:	8556                	mv	a0,s5
 72e:	00000097          	auipc	ra,0x0
 732:	e08080e7          	jalr	-504(ra) # 536 <putc>
 736:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 738:	03c9d793          	srli	a5,s3,0x3c
 73c:	97de                	add	a5,a5,s7
 73e:	0007c583          	lbu	a1,0(a5)
 742:	8556                	mv	a0,s5
 744:	00000097          	auipc	ra,0x0
 748:	df2080e7          	jalr	-526(ra) # 536 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 74c:	0992                	slli	s3,s3,0x4
 74e:	397d                	addiw	s2,s2,-1
 750:	fe0914e3          	bnez	s2,738 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 754:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 758:	4981                	li	s3,0
 75a:	b721                	j	662 <vprintf+0x60>
        s = va_arg(ap, char*);
 75c:	008b0993          	addi	s3,s6,8
 760:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 764:	02090163          	beqz	s2,786 <vprintf+0x184>
        while(*s != 0){
 768:	00094583          	lbu	a1,0(s2)
 76c:	c9a1                	beqz	a1,7bc <vprintf+0x1ba>
          putc(fd, *s);
 76e:	8556                	mv	a0,s5
 770:	00000097          	auipc	ra,0x0
 774:	dc6080e7          	jalr	-570(ra) # 536 <putc>
          s++;
 778:	0905                	addi	s2,s2,1
        while(*s != 0){
 77a:	00094583          	lbu	a1,0(s2)
 77e:	f9e5                	bnez	a1,76e <vprintf+0x16c>
        s = va_arg(ap, char*);
 780:	8b4e                	mv	s6,s3
      state = 0;
 782:	4981                	li	s3,0
 784:	bdf9                	j	662 <vprintf+0x60>
          s = "(null)";
 786:	00000917          	auipc	s2,0x0
 78a:	24a90913          	addi	s2,s2,586 # 9d0 <malloc+0x104>
        while(*s != 0){
 78e:	02800593          	li	a1,40
 792:	bff1                	j	76e <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 794:	008b0913          	addi	s2,s6,8
 798:	000b4583          	lbu	a1,0(s6)
 79c:	8556                	mv	a0,s5
 79e:	00000097          	auipc	ra,0x0
 7a2:	d98080e7          	jalr	-616(ra) # 536 <putc>
 7a6:	8b4a                	mv	s6,s2
      state = 0;
 7a8:	4981                	li	s3,0
 7aa:	bd65                	j	662 <vprintf+0x60>
        putc(fd, c);
 7ac:	85d2                	mv	a1,s4
 7ae:	8556                	mv	a0,s5
 7b0:	00000097          	auipc	ra,0x0
 7b4:	d86080e7          	jalr	-634(ra) # 536 <putc>
      state = 0;
 7b8:	4981                	li	s3,0
 7ba:	b565                	j	662 <vprintf+0x60>
        s = va_arg(ap, char*);
 7bc:	8b4e                	mv	s6,s3
      state = 0;
 7be:	4981                	li	s3,0
 7c0:	b54d                	j	662 <vprintf+0x60>
    }
  }
}
 7c2:	70e6                	ld	ra,120(sp)
 7c4:	7446                	ld	s0,112(sp)
 7c6:	74a6                	ld	s1,104(sp)
 7c8:	7906                	ld	s2,96(sp)
 7ca:	69e6                	ld	s3,88(sp)
 7cc:	6a46                	ld	s4,80(sp)
 7ce:	6aa6                	ld	s5,72(sp)
 7d0:	6b06                	ld	s6,64(sp)
 7d2:	7be2                	ld	s7,56(sp)
 7d4:	7c42                	ld	s8,48(sp)
 7d6:	7ca2                	ld	s9,40(sp)
 7d8:	7d02                	ld	s10,32(sp)
 7da:	6de2                	ld	s11,24(sp)
 7dc:	6109                	addi	sp,sp,128
 7de:	8082                	ret

00000000000007e0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7e0:	715d                	addi	sp,sp,-80
 7e2:	ec06                	sd	ra,24(sp)
 7e4:	e822                	sd	s0,16(sp)
 7e6:	1000                	addi	s0,sp,32
 7e8:	e010                	sd	a2,0(s0)
 7ea:	e414                	sd	a3,8(s0)
 7ec:	e818                	sd	a4,16(s0)
 7ee:	ec1c                	sd	a5,24(s0)
 7f0:	03043023          	sd	a6,32(s0)
 7f4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7f8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7fc:	8622                	mv	a2,s0
 7fe:	00000097          	auipc	ra,0x0
 802:	e04080e7          	jalr	-508(ra) # 602 <vprintf>
}
 806:	60e2                	ld	ra,24(sp)
 808:	6442                	ld	s0,16(sp)
 80a:	6161                	addi	sp,sp,80
 80c:	8082                	ret

000000000000080e <printf>:

void
printf(const char *fmt, ...)
{
 80e:	711d                	addi	sp,sp,-96
 810:	ec06                	sd	ra,24(sp)
 812:	e822                	sd	s0,16(sp)
 814:	1000                	addi	s0,sp,32
 816:	e40c                	sd	a1,8(s0)
 818:	e810                	sd	a2,16(s0)
 81a:	ec14                	sd	a3,24(s0)
 81c:	f018                	sd	a4,32(s0)
 81e:	f41c                	sd	a5,40(s0)
 820:	03043823          	sd	a6,48(s0)
 824:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 828:	00840613          	addi	a2,s0,8
 82c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 830:	85aa                	mv	a1,a0
 832:	4505                	li	a0,1
 834:	00000097          	auipc	ra,0x0
 838:	dce080e7          	jalr	-562(ra) # 602 <vprintf>
}
 83c:	60e2                	ld	ra,24(sp)
 83e:	6442                	ld	s0,16(sp)
 840:	6125                	addi	sp,sp,96
 842:	8082                	ret

0000000000000844 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 844:	1141                	addi	sp,sp,-16
 846:	e422                	sd	s0,8(sp)
 848:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 84a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 84e:	00000797          	auipc	a5,0x0
 852:	1aa7b783          	ld	a5,426(a5) # 9f8 <freep>
 856:	a805                	j	886 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 858:	4618                	lw	a4,8(a2)
 85a:	9db9                	addw	a1,a1,a4
 85c:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 860:	6398                	ld	a4,0(a5)
 862:	6318                	ld	a4,0(a4)
 864:	fee53823          	sd	a4,-16(a0)
 868:	a091                	j	8ac <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 86a:	ff852703          	lw	a4,-8(a0)
 86e:	9e39                	addw	a2,a2,a4
 870:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 872:	ff053703          	ld	a4,-16(a0)
 876:	e398                	sd	a4,0(a5)
 878:	a099                	j	8be <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 87a:	6398                	ld	a4,0(a5)
 87c:	00e7e463          	bltu	a5,a4,884 <free+0x40>
 880:	00e6ea63          	bltu	a3,a4,894 <free+0x50>
{
 884:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 886:	fed7fae3          	bgeu	a5,a3,87a <free+0x36>
 88a:	6398                	ld	a4,0(a5)
 88c:	00e6e463          	bltu	a3,a4,894 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 890:	fee7eae3          	bltu	a5,a4,884 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 894:	ff852583          	lw	a1,-8(a0)
 898:	6390                	ld	a2,0(a5)
 89a:	02059713          	slli	a4,a1,0x20
 89e:	9301                	srli	a4,a4,0x20
 8a0:	0712                	slli	a4,a4,0x4
 8a2:	9736                	add	a4,a4,a3
 8a4:	fae60ae3          	beq	a2,a4,858 <free+0x14>
    bp->s.ptr = p->s.ptr;
 8a8:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8ac:	4790                	lw	a2,8(a5)
 8ae:	02061713          	slli	a4,a2,0x20
 8b2:	9301                	srli	a4,a4,0x20
 8b4:	0712                	slli	a4,a4,0x4
 8b6:	973e                	add	a4,a4,a5
 8b8:	fae689e3          	beq	a3,a4,86a <free+0x26>
  } else
    p->s.ptr = bp;
 8bc:	e394                	sd	a3,0(a5)
  freep = p;
 8be:	00000717          	auipc	a4,0x0
 8c2:	12f73d23          	sd	a5,314(a4) # 9f8 <freep>
}
 8c6:	6422                	ld	s0,8(sp)
 8c8:	0141                	addi	sp,sp,16
 8ca:	8082                	ret

00000000000008cc <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8cc:	7139                	addi	sp,sp,-64
 8ce:	fc06                	sd	ra,56(sp)
 8d0:	f822                	sd	s0,48(sp)
 8d2:	f426                	sd	s1,40(sp)
 8d4:	f04a                	sd	s2,32(sp)
 8d6:	ec4e                	sd	s3,24(sp)
 8d8:	e852                	sd	s4,16(sp)
 8da:	e456                	sd	s5,8(sp)
 8dc:	e05a                	sd	s6,0(sp)
 8de:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8e0:	02051493          	slli	s1,a0,0x20
 8e4:	9081                	srli	s1,s1,0x20
 8e6:	04bd                	addi	s1,s1,15
 8e8:	8091                	srli	s1,s1,0x4
 8ea:	0014899b          	addiw	s3,s1,1
 8ee:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8f0:	00000517          	auipc	a0,0x0
 8f4:	10853503          	ld	a0,264(a0) # 9f8 <freep>
 8f8:	c515                	beqz	a0,924 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8fa:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8fc:	4798                	lw	a4,8(a5)
 8fe:	02977f63          	bgeu	a4,s1,93c <malloc+0x70>
 902:	8a4e                	mv	s4,s3
 904:	0009871b          	sext.w	a4,s3
 908:	6685                	lui	a3,0x1
 90a:	00d77363          	bgeu	a4,a3,910 <malloc+0x44>
 90e:	6a05                	lui	s4,0x1
 910:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 914:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 918:	00000917          	auipc	s2,0x0
 91c:	0e090913          	addi	s2,s2,224 # 9f8 <freep>
  if(p == (char*)-1)
 920:	5afd                	li	s5,-1
 922:	a88d                	j	994 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 924:	00000797          	auipc	a5,0x0
 928:	0dc78793          	addi	a5,a5,220 # a00 <base>
 92c:	00000717          	auipc	a4,0x0
 930:	0cf73623          	sd	a5,204(a4) # 9f8 <freep>
 934:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 936:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 93a:	b7e1                	j	902 <malloc+0x36>
      if(p->s.size == nunits)
 93c:	02e48b63          	beq	s1,a4,972 <malloc+0xa6>
        p->s.size -= nunits;
 940:	4137073b          	subw	a4,a4,s3
 944:	c798                	sw	a4,8(a5)
        p += p->s.size;
 946:	1702                	slli	a4,a4,0x20
 948:	9301                	srli	a4,a4,0x20
 94a:	0712                	slli	a4,a4,0x4
 94c:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 94e:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 952:	00000717          	auipc	a4,0x0
 956:	0aa73323          	sd	a0,166(a4) # 9f8 <freep>
      return (void*)(p + 1);
 95a:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 95e:	70e2                	ld	ra,56(sp)
 960:	7442                	ld	s0,48(sp)
 962:	74a2                	ld	s1,40(sp)
 964:	7902                	ld	s2,32(sp)
 966:	69e2                	ld	s3,24(sp)
 968:	6a42                	ld	s4,16(sp)
 96a:	6aa2                	ld	s5,8(sp)
 96c:	6b02                	ld	s6,0(sp)
 96e:	6121                	addi	sp,sp,64
 970:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 972:	6398                	ld	a4,0(a5)
 974:	e118                	sd	a4,0(a0)
 976:	bff1                	j	952 <malloc+0x86>
  hp->s.size = nu;
 978:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 97c:	0541                	addi	a0,a0,16
 97e:	00000097          	auipc	ra,0x0
 982:	ec6080e7          	jalr	-314(ra) # 844 <free>
  return freep;
 986:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 98a:	d971                	beqz	a0,95e <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 98c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 98e:	4798                	lw	a4,8(a5)
 990:	fa9776e3          	bgeu	a4,s1,93c <malloc+0x70>
    if(p == freep)
 994:	00093703          	ld	a4,0(s2)
 998:	853e                	mv	a0,a5
 99a:	fef719e3          	bne	a4,a5,98c <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 99e:	8552                	mv	a0,s4
 9a0:	00000097          	auipc	ra,0x0
 9a4:	b7e080e7          	jalr	-1154(ra) # 51e <sbrk>
  if(p == (char*)-1)
 9a8:	fd5518e3          	bne	a0,s5,978 <malloc+0xac>
        return 0;
 9ac:	4501                	li	a0,0
 9ae:	bf45                	j	95e <malloc+0x92>
