
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <run>:
// 	exit(0);
// }


// 带参数列表，执行某个程序
void run(char *program, char **args) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84aa                	mv	s1,a0
   e:	892e                	mv	s2,a1
	if(fork() == 0) { // child exec
  10:	00000097          	auipc	ra,0x0
  14:	3b0080e7          	jalr	944(ra) # 3c0 <fork>
  18:	c519                	beqz	a0,26 <run+0x26>
		exec(program, args);
		exit(0);
	}
	return; // parent return
}
  1a:	60e2                	ld	ra,24(sp)
  1c:	6442                	ld	s0,16(sp)
  1e:	64a2                	ld	s1,8(sp)
  20:	6902                	ld	s2,0(sp)
  22:	6105                	addi	sp,sp,32
  24:	8082                	ret
		exec(program, args);
  26:	85ca                	mv	a1,s2
  28:	8526                	mv	a0,s1
  2a:	00000097          	auipc	ra,0x0
  2e:	3d6080e7          	jalr	982(ra) # 400 <exec>
		exit(0);
  32:	4501                	li	a0,0
  34:	00000097          	auipc	ra,0x0
  38:	394080e7          	jalr	916(ra) # 3c8 <exit>

000000000000003c <main>:
// echo 1\n2 | xargs echo hello
int main(int argc, char *argv[]){
  3c:	81010113          	addi	sp,sp,-2032
  40:	7e113423          	sd	ra,2024(sp)
  44:	7e813023          	sd	s0,2016(sp)
  48:	7c913c23          	sd	s1,2008(sp)
  4c:	7d213823          	sd	s2,2000(sp)
  50:	7d313423          	sd	s3,1992(sp)
  54:	7d413023          	sd	s4,1984(sp)
  58:	7b513c23          	sd	s5,1976(sp)
  5c:	7b613823          	sd	s6,1968(sp)
  60:	7b713423          	sd	s7,1960(sp)
  64:	7b813023          	sd	s8,1952(sp)
  68:	79913c23          	sd	s9,1944(sp)
  6c:	7f010413          	addi	s0,sp,2032
  70:	b9010113          	addi	sp,sp,-1136
  74:	89ae                	mv	s3,a1
	char buf[2048]; // 读入时使用的内存池
	char *p = buf, *last_p = buf; // 当前参数的结束、开始指针
	char *argsbuf[128]; // 全部参数列表，字符串指针数组，包含 argv 传进来的参数和 stdin 读入的参数
	char **args = argsbuf; // 指向 argsbuf 中第一个从 stdin 读入的参数
	for(int i=1;i<argc;i++) {
  76:	4785                	li	a5,1
  78:	06a7d163          	bge	a5,a0,da <main+0x9e>
  7c:	00858713          	addi	a4,a1,8
  80:	77fd                	lui	a5,0xfffff
  82:	40078793          	addi	a5,a5,1024 # fffffffffffff400 <__global_pointer$+0xffffffffffffe2ff>
  86:	fa040693          	addi	a3,s0,-96
  8a:	97b6                	add	a5,a5,a3
  8c:	ffe5091b          	addiw	s2,a0,-2
  90:	1902                	slli	s2,s2,0x20
  92:	02095913          	srli	s2,s2,0x20
  96:	0905                	addi	s2,s2,1
  98:	090e                	slli	s2,s2,0x3
  9a:	993e                	add	s2,s2,a5
		// 将 argv 提供的参数加入到最终的参数列表中
		*args = argv[i];
  9c:	6314                	ld	a3,0(a4)
  9e:	e394                	sd	a3,0(a5)
		args++;
  a0:	07a1                	addi	a5,a5,8
	for(int i=1;i<argc;i++) {
  a2:	0721                	addi	a4,a4,8
  a4:	ff279ce3          	bne	a5,s2,9c <main+0x60>
	}
	char **pa = args; // 开始读入参数
	int oldp = 0;
	*p = 0;
  a8:	77fd                	lui	a5,0xfffff
  aa:	7a078713          	addi	a4,a5,1952 # fffffffffffff7a0 <__global_pointer$+0xffffffffffffe69f>
  ae:	9722                	add	a4,a4,s0
  b0:	00070023          	sb	zero,0(a4)
	p++;
	last_p++;
  b4:	7a178713          	addi	a4,a5,1953
  b8:	00e40a33          	add	s4,s0,a4
	p++;
  bc:	84d2                	mv	s1,s4
	while(read(0, p, 1) != 0) {
		if(*p == ' ' || (*(p-1) == '\\' && *p == 'n') || *p == '\n') {
  be:	02000b13          	li	s6,32
			last_p = p+1;
			
			if(oldp == 1) {
				// 读入一行完成
				*pa = 0; // 参数列表末尾用 null 标识列表结束
				run(argv[1], argsbuf); // 执行最后一行指令
  c2:	7afd                	lui	s5,0xfffff
  c4:	400a8a93          	addi	s5,s5,1024 # fffffffffffff400 <__global_pointer$+0xffffffffffffe2ff>
  c8:	fa040793          	addi	a5,s0,-96
  cc:	9abe                	add	s5,s5,a5
		if(*p == ' ' || (*(p-1) == '\\' && *p == 'n') || *p == '\n') {
  ce:	05c00b93          	li	s7,92
  d2:	4c29                	li	s8,10
  d4:	06e00c93          	li	s9,110
	while(read(0, p, 1) != 0) {
  d8:	a82d                	j	112 <main+0xd6>
	char **args = argsbuf; // 指向 argsbuf 中第一个从 stdin 读入的参数
  da:	797d                	lui	s2,0xfffff
  dc:	40090913          	addi	s2,s2,1024 # fffffffffffff400 <__global_pointer$+0xffffffffffffe2ff>
  e0:	fa040793          	addi	a5,s0,-96
  e4:	993e                	add	s2,s2,a5
  e6:	b7c9                	j	a8 <main+0x6c>
		if(*p == ' ' || (*(p-1) == '\\' && *p == 'n') || *p == '\n') {
  e8:	05979563          	bne	a5,s9,132 <main+0xf6>
				*(p-1) = '\0';	// 将空格替换为 \0 分割开各个参数，这样可以直接使用内存池中的字符串作为参数字符串
  ec:	fe048fa3          	sb	zero,-1(s1)
  f0:	a019                	j	f6 <main+0xba>
				*p = '\0';
  f2:	00048023          	sb	zero,0(s1)
			*(pa++) = last_p;
  f6:	01493023          	sd	s4,0(s2)
			last_p = p+1;
  fa:	00148a13          	addi	s4,s1,1
				*pa = 0; // 参数列表末尾用 null 标识列表结束
  fe:	00093423          	sd	zero,8(s2)
				run(argv[1], argsbuf); // 执行最后一行指令
 102:	85d6                	mv	a1,s5
 104:	0089b503          	ld	a0,8(s3)
 108:	00000097          	auipc	ra,0x0
 10c:	ef8080e7          	jalr	-264(ra) # 0 <run>
				pa = args; // 重置读入参数指针，准备读入下一行
				oldp = 0;
			}
		}
		p++;
 110:	0485                	addi	s1,s1,1
	while(read(0, p, 1) != 0) {
 112:	4605                	li	a2,1
 114:	85a6                	mv	a1,s1
 116:	4501                	li	a0,0
 118:	00000097          	auipc	ra,0x0
 11c:	2c8080e7          	jalr	712(ra) # 3e0 <read>
 120:	cd01                	beqz	a0,138 <main+0xfc>
		if(*p == ' ' || (*(p-1) == '\\' && *p == 'n') || *p == '\n') {
 122:	0004c783          	lbu	a5,0(s1)
 126:	fd6786e3          	beq	a5,s6,f2 <main+0xb6>
 12a:	fff4c703          	lbu	a4,-1(s1)
 12e:	fb770de3          	beq	a4,s7,e8 <main+0xac>
 132:	fd879fe3          	bne	a5,s8,110 <main+0xd4>
 136:	bf75                	j	f2 <main+0xb6>
		// 收尾最后一行
		*pa = 0; // 参数列表末尾用 null 标识列表结束
		// 执行最后一行指令
		run(argv[1], argsbuf);
	}
	while(wait(0) != -1) {}; // 循环等待所有子进程完成，每一次 wait(0) 等待一个
 138:	54fd                	li	s1,-1
 13a:	4501                	li	a0,0
 13c:	00000097          	auipc	ra,0x0
 140:	294080e7          	jalr	660(ra) # 3d0 <wait>
 144:	fe951be3          	bne	a0,s1,13a <main+0xfe>
	exit(0);
 148:	4501                	li	a0,0
 14a:	00000097          	auipc	ra,0x0
 14e:	27e080e7          	jalr	638(ra) # 3c8 <exit>

0000000000000152 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 152:	1141                	addi	sp,sp,-16
 154:	e422                	sd	s0,8(sp)
 156:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 158:	87aa                	mv	a5,a0
 15a:	0585                	addi	a1,a1,1
 15c:	0785                	addi	a5,a5,1
 15e:	fff5c703          	lbu	a4,-1(a1)
 162:	fee78fa3          	sb	a4,-1(a5)
 166:	fb75                	bnez	a4,15a <strcpy+0x8>
    ;
  return os;
}
 168:	6422                	ld	s0,8(sp)
 16a:	0141                	addi	sp,sp,16
 16c:	8082                	ret

000000000000016e <strcmp>:

int
strcmp(const char *p, const char *q)
{
 16e:	1141                	addi	sp,sp,-16
 170:	e422                	sd	s0,8(sp)
 172:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 174:	00054783          	lbu	a5,0(a0)
 178:	cb91                	beqz	a5,18c <strcmp+0x1e>
 17a:	0005c703          	lbu	a4,0(a1)
 17e:	00f71763          	bne	a4,a5,18c <strcmp+0x1e>
    p++, q++;
 182:	0505                	addi	a0,a0,1
 184:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 186:	00054783          	lbu	a5,0(a0)
 18a:	fbe5                	bnez	a5,17a <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 18c:	0005c503          	lbu	a0,0(a1)
}
 190:	40a7853b          	subw	a0,a5,a0
 194:	6422                	ld	s0,8(sp)
 196:	0141                	addi	sp,sp,16
 198:	8082                	ret

000000000000019a <strlen>:

uint
strlen(const char *s)
{
 19a:	1141                	addi	sp,sp,-16
 19c:	e422                	sd	s0,8(sp)
 19e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1a0:	00054783          	lbu	a5,0(a0)
 1a4:	cf91                	beqz	a5,1c0 <strlen+0x26>
 1a6:	0505                	addi	a0,a0,1
 1a8:	87aa                	mv	a5,a0
 1aa:	4685                	li	a3,1
 1ac:	9e89                	subw	a3,a3,a0
 1ae:	00f6853b          	addw	a0,a3,a5
 1b2:	0785                	addi	a5,a5,1
 1b4:	fff7c703          	lbu	a4,-1(a5)
 1b8:	fb7d                	bnez	a4,1ae <strlen+0x14>
    ;
  return n;
}
 1ba:	6422                	ld	s0,8(sp)
 1bc:	0141                	addi	sp,sp,16
 1be:	8082                	ret
  for(n = 0; s[n]; n++)
 1c0:	4501                	li	a0,0
 1c2:	bfe5                	j	1ba <strlen+0x20>

00000000000001c4 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1c4:	1141                	addi	sp,sp,-16
 1c6:	e422                	sd	s0,8(sp)
 1c8:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 1ca:	ce09                	beqz	a2,1e4 <memset+0x20>
 1cc:	87aa                	mv	a5,a0
 1ce:	fff6071b          	addiw	a4,a2,-1
 1d2:	1702                	slli	a4,a4,0x20
 1d4:	9301                	srli	a4,a4,0x20
 1d6:	0705                	addi	a4,a4,1
 1d8:	972a                	add	a4,a4,a0
    cdst[i] = c;
 1da:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 1de:	0785                	addi	a5,a5,1
 1e0:	fee79de3          	bne	a5,a4,1da <memset+0x16>
  }
  return dst;
}
 1e4:	6422                	ld	s0,8(sp)
 1e6:	0141                	addi	sp,sp,16
 1e8:	8082                	ret

00000000000001ea <strchr>:

char*
strchr(const char *s, char c)
{
 1ea:	1141                	addi	sp,sp,-16
 1ec:	e422                	sd	s0,8(sp)
 1ee:	0800                	addi	s0,sp,16
  for(; *s; s++)
 1f0:	00054783          	lbu	a5,0(a0)
 1f4:	cb99                	beqz	a5,20a <strchr+0x20>
    if(*s == c)
 1f6:	00f58763          	beq	a1,a5,204 <strchr+0x1a>
  for(; *s; s++)
 1fa:	0505                	addi	a0,a0,1
 1fc:	00054783          	lbu	a5,0(a0)
 200:	fbfd                	bnez	a5,1f6 <strchr+0xc>
      return (char*)s;
  return 0;
 202:	4501                	li	a0,0
}
 204:	6422                	ld	s0,8(sp)
 206:	0141                	addi	sp,sp,16
 208:	8082                	ret
  return 0;
 20a:	4501                	li	a0,0
 20c:	bfe5                	j	204 <strchr+0x1a>

000000000000020e <gets>:

char*
gets(char *buf, int max)
{
 20e:	711d                	addi	sp,sp,-96
 210:	ec86                	sd	ra,88(sp)
 212:	e8a2                	sd	s0,80(sp)
 214:	e4a6                	sd	s1,72(sp)
 216:	e0ca                	sd	s2,64(sp)
 218:	fc4e                	sd	s3,56(sp)
 21a:	f852                	sd	s4,48(sp)
 21c:	f456                	sd	s5,40(sp)
 21e:	f05a                	sd	s6,32(sp)
 220:	ec5e                	sd	s7,24(sp)
 222:	1080                	addi	s0,sp,96
 224:	8baa                	mv	s7,a0
 226:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 228:	892a                	mv	s2,a0
 22a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 22c:	4aa9                	li	s5,10
 22e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 230:	89a6                	mv	s3,s1
 232:	2485                	addiw	s1,s1,1
 234:	0344d863          	bge	s1,s4,264 <gets+0x56>
    cc = read(0, &c, 1);
 238:	4605                	li	a2,1
 23a:	faf40593          	addi	a1,s0,-81
 23e:	4501                	li	a0,0
 240:	00000097          	auipc	ra,0x0
 244:	1a0080e7          	jalr	416(ra) # 3e0 <read>
    if(cc < 1)
 248:	00a05e63          	blez	a0,264 <gets+0x56>
    buf[i++] = c;
 24c:	faf44783          	lbu	a5,-81(s0)
 250:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 254:	01578763          	beq	a5,s5,262 <gets+0x54>
 258:	0905                	addi	s2,s2,1
 25a:	fd679be3          	bne	a5,s6,230 <gets+0x22>
  for(i=0; i+1 < max; ){
 25e:	89a6                	mv	s3,s1
 260:	a011                	j	264 <gets+0x56>
 262:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 264:	99de                	add	s3,s3,s7
 266:	00098023          	sb	zero,0(s3)
  return buf;
}
 26a:	855e                	mv	a0,s7
 26c:	60e6                	ld	ra,88(sp)
 26e:	6446                	ld	s0,80(sp)
 270:	64a6                	ld	s1,72(sp)
 272:	6906                	ld	s2,64(sp)
 274:	79e2                	ld	s3,56(sp)
 276:	7a42                	ld	s4,48(sp)
 278:	7aa2                	ld	s5,40(sp)
 27a:	7b02                	ld	s6,32(sp)
 27c:	6be2                	ld	s7,24(sp)
 27e:	6125                	addi	sp,sp,96
 280:	8082                	ret

0000000000000282 <stat>:

int
stat(const char *n, struct stat *st)
{
 282:	1101                	addi	sp,sp,-32
 284:	ec06                	sd	ra,24(sp)
 286:	e822                	sd	s0,16(sp)
 288:	e426                	sd	s1,8(sp)
 28a:	e04a                	sd	s2,0(sp)
 28c:	1000                	addi	s0,sp,32
 28e:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 290:	4581                	li	a1,0
 292:	00000097          	auipc	ra,0x0
 296:	176080e7          	jalr	374(ra) # 408 <open>
  if(fd < 0)
 29a:	02054563          	bltz	a0,2c4 <stat+0x42>
 29e:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2a0:	85ca                	mv	a1,s2
 2a2:	00000097          	auipc	ra,0x0
 2a6:	17e080e7          	jalr	382(ra) # 420 <fstat>
 2aa:	892a                	mv	s2,a0
  close(fd);
 2ac:	8526                	mv	a0,s1
 2ae:	00000097          	auipc	ra,0x0
 2b2:	142080e7          	jalr	322(ra) # 3f0 <close>
  return r;
}
 2b6:	854a                	mv	a0,s2
 2b8:	60e2                	ld	ra,24(sp)
 2ba:	6442                	ld	s0,16(sp)
 2bc:	64a2                	ld	s1,8(sp)
 2be:	6902                	ld	s2,0(sp)
 2c0:	6105                	addi	sp,sp,32
 2c2:	8082                	ret
    return -1;
 2c4:	597d                	li	s2,-1
 2c6:	bfc5                	j	2b6 <stat+0x34>

00000000000002c8 <atoi>:

int
atoi(const char *s)
{
 2c8:	1141                	addi	sp,sp,-16
 2ca:	e422                	sd	s0,8(sp)
 2cc:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 2ce:	00054603          	lbu	a2,0(a0)
 2d2:	fd06079b          	addiw	a5,a2,-48
 2d6:	0ff7f793          	andi	a5,a5,255
 2da:	4725                	li	a4,9
 2dc:	02f76963          	bltu	a4,a5,30e <atoi+0x46>
 2e0:	86aa                	mv	a3,a0
  n = 0;
 2e2:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 2e4:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 2e6:	0685                	addi	a3,a3,1
 2e8:	0025179b          	slliw	a5,a0,0x2
 2ec:	9fa9                	addw	a5,a5,a0
 2ee:	0017979b          	slliw	a5,a5,0x1
 2f2:	9fb1                	addw	a5,a5,a2
 2f4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 2f8:	0006c603          	lbu	a2,0(a3)
 2fc:	fd06071b          	addiw	a4,a2,-48
 300:	0ff77713          	andi	a4,a4,255
 304:	fee5f1e3          	bgeu	a1,a4,2e6 <atoi+0x1e>
  return n;
}
 308:	6422                	ld	s0,8(sp)
 30a:	0141                	addi	sp,sp,16
 30c:	8082                	ret
  n = 0;
 30e:	4501                	li	a0,0
 310:	bfe5                	j	308 <atoi+0x40>

0000000000000312 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 312:	1141                	addi	sp,sp,-16
 314:	e422                	sd	s0,8(sp)
 316:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 318:	02b57663          	bgeu	a0,a1,344 <memmove+0x32>
    while(n-- > 0)
 31c:	02c05163          	blez	a2,33e <memmove+0x2c>
 320:	fff6079b          	addiw	a5,a2,-1
 324:	1782                	slli	a5,a5,0x20
 326:	9381                	srli	a5,a5,0x20
 328:	0785                	addi	a5,a5,1
 32a:	97aa                	add	a5,a5,a0
  dst = vdst;
 32c:	872a                	mv	a4,a0
      *dst++ = *src++;
 32e:	0585                	addi	a1,a1,1
 330:	0705                	addi	a4,a4,1
 332:	fff5c683          	lbu	a3,-1(a1)
 336:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 33a:	fee79ae3          	bne	a5,a4,32e <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 33e:	6422                	ld	s0,8(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret
    dst += n;
 344:	00c50733          	add	a4,a0,a2
    src += n;
 348:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 34a:	fec05ae3          	blez	a2,33e <memmove+0x2c>
 34e:	fff6079b          	addiw	a5,a2,-1
 352:	1782                	slli	a5,a5,0x20
 354:	9381                	srli	a5,a5,0x20
 356:	fff7c793          	not	a5,a5
 35a:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 35c:	15fd                	addi	a1,a1,-1
 35e:	177d                	addi	a4,a4,-1
 360:	0005c683          	lbu	a3,0(a1)
 364:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 368:	fee79ae3          	bne	a5,a4,35c <memmove+0x4a>
 36c:	bfc9                	j	33e <memmove+0x2c>

000000000000036e <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 36e:	1141                	addi	sp,sp,-16
 370:	e422                	sd	s0,8(sp)
 372:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 374:	ca05                	beqz	a2,3a4 <memcmp+0x36>
 376:	fff6069b          	addiw	a3,a2,-1
 37a:	1682                	slli	a3,a3,0x20
 37c:	9281                	srli	a3,a3,0x20
 37e:	0685                	addi	a3,a3,1
 380:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 382:	00054783          	lbu	a5,0(a0)
 386:	0005c703          	lbu	a4,0(a1)
 38a:	00e79863          	bne	a5,a4,39a <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 38e:	0505                	addi	a0,a0,1
    p2++;
 390:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 392:	fed518e3          	bne	a0,a3,382 <memcmp+0x14>
  }
  return 0;
 396:	4501                	li	a0,0
 398:	a019                	j	39e <memcmp+0x30>
      return *p1 - *p2;
 39a:	40e7853b          	subw	a0,a5,a4
}
 39e:	6422                	ld	s0,8(sp)
 3a0:	0141                	addi	sp,sp,16
 3a2:	8082                	ret
  return 0;
 3a4:	4501                	li	a0,0
 3a6:	bfe5                	j	39e <memcmp+0x30>

00000000000003a8 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3a8:	1141                	addi	sp,sp,-16
 3aa:	e406                	sd	ra,8(sp)
 3ac:	e022                	sd	s0,0(sp)
 3ae:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3b0:	00000097          	auipc	ra,0x0
 3b4:	f62080e7          	jalr	-158(ra) # 312 <memmove>
}
 3b8:	60a2                	ld	ra,8(sp)
 3ba:	6402                	ld	s0,0(sp)
 3bc:	0141                	addi	sp,sp,16
 3be:	8082                	ret

00000000000003c0 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 3c0:	4885                	li	a7,1
 ecall
 3c2:	00000073          	ecall
 ret
 3c6:	8082                	ret

00000000000003c8 <exit>:
.global exit
exit:
 li a7, SYS_exit
 3c8:	4889                	li	a7,2
 ecall
 3ca:	00000073          	ecall
 ret
 3ce:	8082                	ret

00000000000003d0 <wait>:
.global wait
wait:
 li a7, SYS_wait
 3d0:	488d                	li	a7,3
 ecall
 3d2:	00000073          	ecall
 ret
 3d6:	8082                	ret

00000000000003d8 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 3d8:	4891                	li	a7,4
 ecall
 3da:	00000073          	ecall
 ret
 3de:	8082                	ret

00000000000003e0 <read>:
.global read
read:
 li a7, SYS_read
 3e0:	4895                	li	a7,5
 ecall
 3e2:	00000073          	ecall
 ret
 3e6:	8082                	ret

00000000000003e8 <write>:
.global write
write:
 li a7, SYS_write
 3e8:	48c1                	li	a7,16
 ecall
 3ea:	00000073          	ecall
 ret
 3ee:	8082                	ret

00000000000003f0 <close>:
.global close
close:
 li a7, SYS_close
 3f0:	48d5                	li	a7,21
 ecall
 3f2:	00000073          	ecall
 ret
 3f6:	8082                	ret

00000000000003f8 <kill>:
.global kill
kill:
 li a7, SYS_kill
 3f8:	4899                	li	a7,6
 ecall
 3fa:	00000073          	ecall
 ret
 3fe:	8082                	ret

0000000000000400 <exec>:
.global exec
exec:
 li a7, SYS_exec
 400:	489d                	li	a7,7
 ecall
 402:	00000073          	ecall
 ret
 406:	8082                	ret

0000000000000408 <open>:
.global open
open:
 li a7, SYS_open
 408:	48bd                	li	a7,15
 ecall
 40a:	00000073          	ecall
 ret
 40e:	8082                	ret

0000000000000410 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 410:	48c5                	li	a7,17
 ecall
 412:	00000073          	ecall
 ret
 416:	8082                	ret

0000000000000418 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 418:	48c9                	li	a7,18
 ecall
 41a:	00000073          	ecall
 ret
 41e:	8082                	ret

0000000000000420 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 420:	48a1                	li	a7,8
 ecall
 422:	00000073          	ecall
 ret
 426:	8082                	ret

0000000000000428 <link>:
.global link
link:
 li a7, SYS_link
 428:	48cd                	li	a7,19
 ecall
 42a:	00000073          	ecall
 ret
 42e:	8082                	ret

0000000000000430 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 430:	48d1                	li	a7,20
 ecall
 432:	00000073          	ecall
 ret
 436:	8082                	ret

0000000000000438 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 438:	48a5                	li	a7,9
 ecall
 43a:	00000073          	ecall
 ret
 43e:	8082                	ret

0000000000000440 <dup>:
.global dup
dup:
 li a7, SYS_dup
 440:	48a9                	li	a7,10
 ecall
 442:	00000073          	ecall
 ret
 446:	8082                	ret

0000000000000448 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 448:	48ad                	li	a7,11
 ecall
 44a:	00000073          	ecall
 ret
 44e:	8082                	ret

0000000000000450 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 450:	48b1                	li	a7,12
 ecall
 452:	00000073          	ecall
 ret
 456:	8082                	ret

0000000000000458 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 458:	48b5                	li	a7,13
 ecall
 45a:	00000073          	ecall
 ret
 45e:	8082                	ret

0000000000000460 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 460:	48b9                	li	a7,14
 ecall
 462:	00000073          	ecall
 ret
 466:	8082                	ret

0000000000000468 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 468:	1101                	addi	sp,sp,-32
 46a:	ec06                	sd	ra,24(sp)
 46c:	e822                	sd	s0,16(sp)
 46e:	1000                	addi	s0,sp,32
 470:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 474:	4605                	li	a2,1
 476:	fef40593          	addi	a1,s0,-17
 47a:	00000097          	auipc	ra,0x0
 47e:	f6e080e7          	jalr	-146(ra) # 3e8 <write>
}
 482:	60e2                	ld	ra,24(sp)
 484:	6442                	ld	s0,16(sp)
 486:	6105                	addi	sp,sp,32
 488:	8082                	ret

000000000000048a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 48a:	7139                	addi	sp,sp,-64
 48c:	fc06                	sd	ra,56(sp)
 48e:	f822                	sd	s0,48(sp)
 490:	f426                	sd	s1,40(sp)
 492:	f04a                	sd	s2,32(sp)
 494:	ec4e                	sd	s3,24(sp)
 496:	0080                	addi	s0,sp,64
 498:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 49a:	c299                	beqz	a3,4a0 <printint+0x16>
 49c:	0805c863          	bltz	a1,52c <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 4a0:	2581                	sext.w	a1,a1
  neg = 0;
 4a2:	4881                	li	a7,0
 4a4:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 4a8:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 4aa:	2601                	sext.w	a2,a2
 4ac:	00000517          	auipc	a0,0x0
 4b0:	44450513          	addi	a0,a0,1092 # 8f0 <digits>
 4b4:	883a                	mv	a6,a4
 4b6:	2705                	addiw	a4,a4,1
 4b8:	02c5f7bb          	remuw	a5,a1,a2
 4bc:	1782                	slli	a5,a5,0x20
 4be:	9381                	srli	a5,a5,0x20
 4c0:	97aa                	add	a5,a5,a0
 4c2:	0007c783          	lbu	a5,0(a5)
 4c6:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 4ca:	0005879b          	sext.w	a5,a1
 4ce:	02c5d5bb          	divuw	a1,a1,a2
 4d2:	0685                	addi	a3,a3,1
 4d4:	fec7f0e3          	bgeu	a5,a2,4b4 <printint+0x2a>
  if(neg)
 4d8:	00088b63          	beqz	a7,4ee <printint+0x64>
    buf[i++] = '-';
 4dc:	fd040793          	addi	a5,s0,-48
 4e0:	973e                	add	a4,a4,a5
 4e2:	02d00793          	li	a5,45
 4e6:	fef70823          	sb	a5,-16(a4)
 4ea:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 4ee:	02e05863          	blez	a4,51e <printint+0x94>
 4f2:	fc040793          	addi	a5,s0,-64
 4f6:	00e78933          	add	s2,a5,a4
 4fa:	fff78993          	addi	s3,a5,-1
 4fe:	99ba                	add	s3,s3,a4
 500:	377d                	addiw	a4,a4,-1
 502:	1702                	slli	a4,a4,0x20
 504:	9301                	srli	a4,a4,0x20
 506:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 50a:	fff94583          	lbu	a1,-1(s2)
 50e:	8526                	mv	a0,s1
 510:	00000097          	auipc	ra,0x0
 514:	f58080e7          	jalr	-168(ra) # 468 <putc>
  while(--i >= 0)
 518:	197d                	addi	s2,s2,-1
 51a:	ff3918e3          	bne	s2,s3,50a <printint+0x80>
}
 51e:	70e2                	ld	ra,56(sp)
 520:	7442                	ld	s0,48(sp)
 522:	74a2                	ld	s1,40(sp)
 524:	7902                	ld	s2,32(sp)
 526:	69e2                	ld	s3,24(sp)
 528:	6121                	addi	sp,sp,64
 52a:	8082                	ret
    x = -xx;
 52c:	40b005bb          	negw	a1,a1
    neg = 1;
 530:	4885                	li	a7,1
    x = -xx;
 532:	bf8d                	j	4a4 <printint+0x1a>

0000000000000534 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 534:	7119                	addi	sp,sp,-128
 536:	fc86                	sd	ra,120(sp)
 538:	f8a2                	sd	s0,112(sp)
 53a:	f4a6                	sd	s1,104(sp)
 53c:	f0ca                	sd	s2,96(sp)
 53e:	ecce                	sd	s3,88(sp)
 540:	e8d2                	sd	s4,80(sp)
 542:	e4d6                	sd	s5,72(sp)
 544:	e0da                	sd	s6,64(sp)
 546:	fc5e                	sd	s7,56(sp)
 548:	f862                	sd	s8,48(sp)
 54a:	f466                	sd	s9,40(sp)
 54c:	f06a                	sd	s10,32(sp)
 54e:	ec6e                	sd	s11,24(sp)
 550:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 552:	0005c903          	lbu	s2,0(a1)
 556:	18090f63          	beqz	s2,6f4 <vprintf+0x1c0>
 55a:	8aaa                	mv	s5,a0
 55c:	8b32                	mv	s6,a2
 55e:	00158493          	addi	s1,a1,1
  state = 0;
 562:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 564:	02500a13          	li	s4,37
      if(c == 'd'){
 568:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 56c:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 570:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 574:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 578:	00000b97          	auipc	s7,0x0
 57c:	378b8b93          	addi	s7,s7,888 # 8f0 <digits>
 580:	a839                	j	59e <vprintf+0x6a>
        putc(fd, c);
 582:	85ca                	mv	a1,s2
 584:	8556                	mv	a0,s5
 586:	00000097          	auipc	ra,0x0
 58a:	ee2080e7          	jalr	-286(ra) # 468 <putc>
 58e:	a019                	j	594 <vprintf+0x60>
    } else if(state == '%'){
 590:	01498f63          	beq	s3,s4,5ae <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 594:	0485                	addi	s1,s1,1
 596:	fff4c903          	lbu	s2,-1(s1)
 59a:	14090d63          	beqz	s2,6f4 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 59e:	0009079b          	sext.w	a5,s2
    if(state == 0){
 5a2:	fe0997e3          	bnez	s3,590 <vprintf+0x5c>
      if(c == '%'){
 5a6:	fd479ee3          	bne	a5,s4,582 <vprintf+0x4e>
        state = '%';
 5aa:	89be                	mv	s3,a5
 5ac:	b7e5                	j	594 <vprintf+0x60>
      if(c == 'd'){
 5ae:	05878063          	beq	a5,s8,5ee <vprintf+0xba>
      } else if(c == 'l') {
 5b2:	05978c63          	beq	a5,s9,60a <vprintf+0xd6>
      } else if(c == 'x') {
 5b6:	07a78863          	beq	a5,s10,626 <vprintf+0xf2>
      } else if(c == 'p') {
 5ba:	09b78463          	beq	a5,s11,642 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 5be:	07300713          	li	a4,115
 5c2:	0ce78663          	beq	a5,a4,68e <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 5c6:	06300713          	li	a4,99
 5ca:	0ee78e63          	beq	a5,a4,6c6 <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 5ce:	11478863          	beq	a5,s4,6de <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5d2:	85d2                	mv	a1,s4
 5d4:	8556                	mv	a0,s5
 5d6:	00000097          	auipc	ra,0x0
 5da:	e92080e7          	jalr	-366(ra) # 468 <putc>
        putc(fd, c);
 5de:	85ca                	mv	a1,s2
 5e0:	8556                	mv	a0,s5
 5e2:	00000097          	auipc	ra,0x0
 5e6:	e86080e7          	jalr	-378(ra) # 468 <putc>
      }
      state = 0;
 5ea:	4981                	li	s3,0
 5ec:	b765                	j	594 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 5ee:	008b0913          	addi	s2,s6,8
 5f2:	4685                	li	a3,1
 5f4:	4629                	li	a2,10
 5f6:	000b2583          	lw	a1,0(s6)
 5fa:	8556                	mv	a0,s5
 5fc:	00000097          	auipc	ra,0x0
 600:	e8e080e7          	jalr	-370(ra) # 48a <printint>
 604:	8b4a                	mv	s6,s2
      state = 0;
 606:	4981                	li	s3,0
 608:	b771                	j	594 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 60a:	008b0913          	addi	s2,s6,8
 60e:	4681                	li	a3,0
 610:	4629                	li	a2,10
 612:	000b2583          	lw	a1,0(s6)
 616:	8556                	mv	a0,s5
 618:	00000097          	auipc	ra,0x0
 61c:	e72080e7          	jalr	-398(ra) # 48a <printint>
 620:	8b4a                	mv	s6,s2
      state = 0;
 622:	4981                	li	s3,0
 624:	bf85                	j	594 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 626:	008b0913          	addi	s2,s6,8
 62a:	4681                	li	a3,0
 62c:	4641                	li	a2,16
 62e:	000b2583          	lw	a1,0(s6)
 632:	8556                	mv	a0,s5
 634:	00000097          	auipc	ra,0x0
 638:	e56080e7          	jalr	-426(ra) # 48a <printint>
 63c:	8b4a                	mv	s6,s2
      state = 0;
 63e:	4981                	li	s3,0
 640:	bf91                	j	594 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 642:	008b0793          	addi	a5,s6,8
 646:	f8f43423          	sd	a5,-120(s0)
 64a:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 64e:	03000593          	li	a1,48
 652:	8556                	mv	a0,s5
 654:	00000097          	auipc	ra,0x0
 658:	e14080e7          	jalr	-492(ra) # 468 <putc>
  putc(fd, 'x');
 65c:	85ea                	mv	a1,s10
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	e08080e7          	jalr	-504(ra) # 468 <putc>
 668:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 66a:	03c9d793          	srli	a5,s3,0x3c
 66e:	97de                	add	a5,a5,s7
 670:	0007c583          	lbu	a1,0(a5)
 674:	8556                	mv	a0,s5
 676:	00000097          	auipc	ra,0x0
 67a:	df2080e7          	jalr	-526(ra) # 468 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 67e:	0992                	slli	s3,s3,0x4
 680:	397d                	addiw	s2,s2,-1
 682:	fe0914e3          	bnez	s2,66a <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 686:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 68a:	4981                	li	s3,0
 68c:	b721                	j	594 <vprintf+0x60>
        s = va_arg(ap, char*);
 68e:	008b0993          	addi	s3,s6,8
 692:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 696:	02090163          	beqz	s2,6b8 <vprintf+0x184>
        while(*s != 0){
 69a:	00094583          	lbu	a1,0(s2)
 69e:	c9a1                	beqz	a1,6ee <vprintf+0x1ba>
          putc(fd, *s);
 6a0:	8556                	mv	a0,s5
 6a2:	00000097          	auipc	ra,0x0
 6a6:	dc6080e7          	jalr	-570(ra) # 468 <putc>
          s++;
 6aa:	0905                	addi	s2,s2,1
        while(*s != 0){
 6ac:	00094583          	lbu	a1,0(s2)
 6b0:	f9e5                	bnez	a1,6a0 <vprintf+0x16c>
        s = va_arg(ap, char*);
 6b2:	8b4e                	mv	s6,s3
      state = 0;
 6b4:	4981                	li	s3,0
 6b6:	bdf9                	j	594 <vprintf+0x60>
          s = "(null)";
 6b8:	00000917          	auipc	s2,0x0
 6bc:	23090913          	addi	s2,s2,560 # 8e8 <malloc+0xea>
        while(*s != 0){
 6c0:	02800593          	li	a1,40
 6c4:	bff1                	j	6a0 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 6c6:	008b0913          	addi	s2,s6,8
 6ca:	000b4583          	lbu	a1,0(s6)
 6ce:	8556                	mv	a0,s5
 6d0:	00000097          	auipc	ra,0x0
 6d4:	d98080e7          	jalr	-616(ra) # 468 <putc>
 6d8:	8b4a                	mv	s6,s2
      state = 0;
 6da:	4981                	li	s3,0
 6dc:	bd65                	j	594 <vprintf+0x60>
        putc(fd, c);
 6de:	85d2                	mv	a1,s4
 6e0:	8556                	mv	a0,s5
 6e2:	00000097          	auipc	ra,0x0
 6e6:	d86080e7          	jalr	-634(ra) # 468 <putc>
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	b565                	j	594 <vprintf+0x60>
        s = va_arg(ap, char*);
 6ee:	8b4e                	mv	s6,s3
      state = 0;
 6f0:	4981                	li	s3,0
 6f2:	b54d                	j	594 <vprintf+0x60>
    }
  }
}
 6f4:	70e6                	ld	ra,120(sp)
 6f6:	7446                	ld	s0,112(sp)
 6f8:	74a6                	ld	s1,104(sp)
 6fa:	7906                	ld	s2,96(sp)
 6fc:	69e6                	ld	s3,88(sp)
 6fe:	6a46                	ld	s4,80(sp)
 700:	6aa6                	ld	s5,72(sp)
 702:	6b06                	ld	s6,64(sp)
 704:	7be2                	ld	s7,56(sp)
 706:	7c42                	ld	s8,48(sp)
 708:	7ca2                	ld	s9,40(sp)
 70a:	7d02                	ld	s10,32(sp)
 70c:	6de2                	ld	s11,24(sp)
 70e:	6109                	addi	sp,sp,128
 710:	8082                	ret

0000000000000712 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 712:	715d                	addi	sp,sp,-80
 714:	ec06                	sd	ra,24(sp)
 716:	e822                	sd	s0,16(sp)
 718:	1000                	addi	s0,sp,32
 71a:	e010                	sd	a2,0(s0)
 71c:	e414                	sd	a3,8(s0)
 71e:	e818                	sd	a4,16(s0)
 720:	ec1c                	sd	a5,24(s0)
 722:	03043023          	sd	a6,32(s0)
 726:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 72a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 72e:	8622                	mv	a2,s0
 730:	00000097          	auipc	ra,0x0
 734:	e04080e7          	jalr	-508(ra) # 534 <vprintf>
}
 738:	60e2                	ld	ra,24(sp)
 73a:	6442                	ld	s0,16(sp)
 73c:	6161                	addi	sp,sp,80
 73e:	8082                	ret

0000000000000740 <printf>:

void
printf(const char *fmt, ...)
{
 740:	711d                	addi	sp,sp,-96
 742:	ec06                	sd	ra,24(sp)
 744:	e822                	sd	s0,16(sp)
 746:	1000                	addi	s0,sp,32
 748:	e40c                	sd	a1,8(s0)
 74a:	e810                	sd	a2,16(s0)
 74c:	ec14                	sd	a3,24(s0)
 74e:	f018                	sd	a4,32(s0)
 750:	f41c                	sd	a5,40(s0)
 752:	03043823          	sd	a6,48(s0)
 756:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 75a:	00840613          	addi	a2,s0,8
 75e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 762:	85aa                	mv	a1,a0
 764:	4505                	li	a0,1
 766:	00000097          	auipc	ra,0x0
 76a:	dce080e7          	jalr	-562(ra) # 534 <vprintf>
}
 76e:	60e2                	ld	ra,24(sp)
 770:	6442                	ld	s0,16(sp)
 772:	6125                	addi	sp,sp,96
 774:	8082                	ret

0000000000000776 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 776:	1141                	addi	sp,sp,-16
 778:	e422                	sd	s0,8(sp)
 77a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 77c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 780:	00000797          	auipc	a5,0x0
 784:	1887b783          	ld	a5,392(a5) # 908 <freep>
 788:	a805                	j	7b8 <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 78a:	4618                	lw	a4,8(a2)
 78c:	9db9                	addw	a1,a1,a4
 78e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 792:	6398                	ld	a4,0(a5)
 794:	6318                	ld	a4,0(a4)
 796:	fee53823          	sd	a4,-16(a0)
 79a:	a091                	j	7de <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 79c:	ff852703          	lw	a4,-8(a0)
 7a0:	9e39                	addw	a2,a2,a4
 7a2:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 7a4:	ff053703          	ld	a4,-16(a0)
 7a8:	e398                	sd	a4,0(a5)
 7aa:	a099                	j	7f0 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ac:	6398                	ld	a4,0(a5)
 7ae:	00e7e463          	bltu	a5,a4,7b6 <free+0x40>
 7b2:	00e6ea63          	bltu	a3,a4,7c6 <free+0x50>
{
 7b6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7b8:	fed7fae3          	bgeu	a5,a3,7ac <free+0x36>
 7bc:	6398                	ld	a4,0(a5)
 7be:	00e6e463          	bltu	a3,a4,7c6 <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c2:	fee7eae3          	bltu	a5,a4,7b6 <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 7c6:	ff852583          	lw	a1,-8(a0)
 7ca:	6390                	ld	a2,0(a5)
 7cc:	02059713          	slli	a4,a1,0x20
 7d0:	9301                	srli	a4,a4,0x20
 7d2:	0712                	slli	a4,a4,0x4
 7d4:	9736                	add	a4,a4,a3
 7d6:	fae60ae3          	beq	a2,a4,78a <free+0x14>
    bp->s.ptr = p->s.ptr;
 7da:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7de:	4790                	lw	a2,8(a5)
 7e0:	02061713          	slli	a4,a2,0x20
 7e4:	9301                	srli	a4,a4,0x20
 7e6:	0712                	slli	a4,a4,0x4
 7e8:	973e                	add	a4,a4,a5
 7ea:	fae689e3          	beq	a3,a4,79c <free+0x26>
  } else
    p->s.ptr = bp;
 7ee:	e394                	sd	a3,0(a5)
  freep = p;
 7f0:	00000717          	auipc	a4,0x0
 7f4:	10f73c23          	sd	a5,280(a4) # 908 <freep>
}
 7f8:	6422                	ld	s0,8(sp)
 7fa:	0141                	addi	sp,sp,16
 7fc:	8082                	ret

00000000000007fe <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7fe:	7139                	addi	sp,sp,-64
 800:	fc06                	sd	ra,56(sp)
 802:	f822                	sd	s0,48(sp)
 804:	f426                	sd	s1,40(sp)
 806:	f04a                	sd	s2,32(sp)
 808:	ec4e                	sd	s3,24(sp)
 80a:	e852                	sd	s4,16(sp)
 80c:	e456                	sd	s5,8(sp)
 80e:	e05a                	sd	s6,0(sp)
 810:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 812:	02051493          	slli	s1,a0,0x20
 816:	9081                	srli	s1,s1,0x20
 818:	04bd                	addi	s1,s1,15
 81a:	8091                	srli	s1,s1,0x4
 81c:	0014899b          	addiw	s3,s1,1
 820:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 822:	00000517          	auipc	a0,0x0
 826:	0e653503          	ld	a0,230(a0) # 908 <freep>
 82a:	c515                	beqz	a0,856 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 82c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 82e:	4798                	lw	a4,8(a5)
 830:	02977f63          	bgeu	a4,s1,86e <malloc+0x70>
 834:	8a4e                	mv	s4,s3
 836:	0009871b          	sext.w	a4,s3
 83a:	6685                	lui	a3,0x1
 83c:	00d77363          	bgeu	a4,a3,842 <malloc+0x44>
 840:	6a05                	lui	s4,0x1
 842:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 846:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 84a:	00000917          	auipc	s2,0x0
 84e:	0be90913          	addi	s2,s2,190 # 908 <freep>
  if(p == (char*)-1)
 852:	5afd                	li	s5,-1
 854:	a88d                	j	8c6 <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 856:	00000797          	auipc	a5,0x0
 85a:	0ba78793          	addi	a5,a5,186 # 910 <base>
 85e:	00000717          	auipc	a4,0x0
 862:	0af73523          	sd	a5,170(a4) # 908 <freep>
 866:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 868:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 86c:	b7e1                	j	834 <malloc+0x36>
      if(p->s.size == nunits)
 86e:	02e48b63          	beq	s1,a4,8a4 <malloc+0xa6>
        p->s.size -= nunits;
 872:	4137073b          	subw	a4,a4,s3
 876:	c798                	sw	a4,8(a5)
        p += p->s.size;
 878:	1702                	slli	a4,a4,0x20
 87a:	9301                	srli	a4,a4,0x20
 87c:	0712                	slli	a4,a4,0x4
 87e:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 880:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 884:	00000717          	auipc	a4,0x0
 888:	08a73223          	sd	a0,132(a4) # 908 <freep>
      return (void*)(p + 1);
 88c:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 890:	70e2                	ld	ra,56(sp)
 892:	7442                	ld	s0,48(sp)
 894:	74a2                	ld	s1,40(sp)
 896:	7902                	ld	s2,32(sp)
 898:	69e2                	ld	s3,24(sp)
 89a:	6a42                	ld	s4,16(sp)
 89c:	6aa2                	ld	s5,8(sp)
 89e:	6b02                	ld	s6,0(sp)
 8a0:	6121                	addi	sp,sp,64
 8a2:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 8a4:	6398                	ld	a4,0(a5)
 8a6:	e118                	sd	a4,0(a0)
 8a8:	bff1                	j	884 <malloc+0x86>
  hp->s.size = nu;
 8aa:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8ae:	0541                	addi	a0,a0,16
 8b0:	00000097          	auipc	ra,0x0
 8b4:	ec6080e7          	jalr	-314(ra) # 776 <free>
  return freep;
 8b8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8bc:	d971                	beqz	a0,890 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8be:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8c0:	4798                	lw	a4,8(a5)
 8c2:	fa9776e3          	bgeu	a4,s1,86e <malloc+0x70>
    if(p == freep)
 8c6:	00093703          	ld	a4,0(s2)
 8ca:	853e                	mv	a0,a5
 8cc:	fef719e3          	bne	a4,a5,8be <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 8d0:	8552                	mv	a0,s4
 8d2:	00000097          	auipc	ra,0x0
 8d6:	b7e080e7          	jalr	-1154(ra) # 450 <sbrk>
  if(p == (char*)-1)
 8da:	fd5518e3          	bne	a0,s5,8aa <malloc+0xac>
        return 0;
 8de:	4501                	li	a0,0
 8e0:	bf45                	j	890 <malloc+0x92>
