
user/_xargs:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <clearArgv>:
#include "kernel/param.h"

#define MAXSZ 512

void clearArgv(char *x_argv[MAXARG], int beg)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
    for (int i = beg; i < MAXARG; ++i)
   6:	47fd                	li	a5,31
   8:	02b7c263          	blt	a5,a1,2c <clearArgv+0x2c>
   c:	00359793          	slli	a5,a1,0x3
  10:	97aa                	add	a5,a5,a0
  12:	477d                	li	a4,31
  14:	9f0d                	subw	a4,a4,a1
  16:	1702                	slli	a4,a4,0x20
  18:	9301                	srli	a4,a4,0x20
  1a:	972e                	add	a4,a4,a1
  1c:	070e                	slli	a4,a4,0x3
  1e:	0521                	addi	a0,a0,8
  20:	972a                	add	a4,a4,a0
        x_argv[i] = 0;
  22:	0007b023          	sd	zero,0(a5)
    for (int i = beg; i < MAXARG; ++i)
  26:	07a1                	addi	a5,a5,8
  28:	fee79de3          	bne	a5,a4,22 <clearArgv+0x22>
}
  2c:	6422                	ld	s0,8(sp)
  2e:	0141                	addi	sp,sp,16
  30:	8082                	ret

0000000000000032 <readline>:

int readline(char *buf, int max)
{
  32:	711d                	addi	sp,sp,-96
  34:	ec86                	sd	ra,88(sp)
  36:	e8a2                	sd	s0,80(sp)
  38:	e4a6                	sd	s1,72(sp)
  3a:	e0ca                	sd	s2,64(sp)
  3c:	fc4e                	sd	s3,56(sp)
  3e:	f852                	sd	s4,48(sp)
  40:	f456                	sd	s5,40(sp)
  42:	f05a                	sd	s6,32(sp)
  44:	ec5e                	sd	s7,24(sp)
  46:	1080                	addi	s0,sp,96
  48:	8b2a                	mv	s6,a0
    int i = 0;
    char c;
    while (i < max - 1)
  4a:	4785                	li	a5,1
  4c:	08b7d463          	bge	a5,a1,d4 <readline+0xa2>
  50:	892a                	mv	s2,a0
  52:	fff5899b          	addiw	s3,a1,-1
    int i = 0;
  56:	4481                	li	s1,0
    {
        int n = read(0, &c, 1);
        if (n <= 0)
            break; // EOF or error
        if (c == '\\')
  58:	05c00a13          	li	s4,92
        {
            // 处理转义序列
            n = read(0, &c, 1);
            if (n <= 0)
                break;
            if (c == 'n')
  5c:	06e00b93          	li	s7,110
                c = '\n'; // 将 \n 转换为换行符
            // 其他转义序列可在此扩展
        }
        if (c == '\n')
  60:	4aa9                	li	s5,10
  62:	a819                	j	78 <readline+0x46>
  64:	faf44783          	lbu	a5,-81(s0)
  68:	05578463          	beq	a5,s5,b0 <readline+0x7e>
            break; // 遇到换行符结束行
        buf[i++] = c;
  6c:	2485                	addiw	s1,s1,1
  6e:	00f90023          	sb	a5,0(s2)
    while (i < max - 1)
  72:	0905                	addi	s2,s2,1
  74:	05348e63          	beq	s1,s3,d0 <readline+0x9e>
        int n = read(0, &c, 1);
  78:	4605                	li	a2,1
  7a:	faf40593          	addi	a1,s0,-81
  7e:	4501                	li	a0,0
  80:	00000097          	auipc	ra,0x0
  84:	424080e7          	jalr	1060(ra) # 4a4 <read>
        if (n <= 0)
  88:	02a05463          	blez	a0,b0 <readline+0x7e>
        if (c == '\\')
  8c:	faf44783          	lbu	a5,-81(s0)
  90:	fd479ae3          	bne	a5,s4,64 <readline+0x32>
            n = read(0, &c, 1);
  94:	4605                	li	a2,1
  96:	faf40593          	addi	a1,s0,-81
  9a:	4501                	li	a0,0
  9c:	00000097          	auipc	ra,0x0
  a0:	408080e7          	jalr	1032(ra) # 4a4 <read>
            if (n <= 0)
  a4:	00a05663          	blez	a0,b0 <readline+0x7e>
            if (c == 'n')
  a8:	faf44783          	lbu	a5,-81(s0)
  ac:	fb779ce3          	bne	a5,s7,64 <readline+0x32>
    }
    buf[i] = '\0';
  b0:	009b0533          	add	a0,s6,s1
  b4:	00050023          	sb	zero,0(a0)
    return i;
}
  b8:	8526                	mv	a0,s1
  ba:	60e6                	ld	ra,88(sp)
  bc:	6446                	ld	s0,80(sp)
  be:	64a6                	ld	s1,72(sp)
  c0:	6906                	ld	s2,64(sp)
  c2:	79e2                	ld	s3,56(sp)
  c4:	7a42                	ld	s4,48(sp)
  c6:	7aa2                	ld	s5,40(sp)
  c8:	7b02                	ld	s6,32(sp)
  ca:	6be2                	ld	s7,24(sp)
  cc:	6125                	addi	sp,sp,96
  ce:	8082                	ret
        buf[i++] = c;
  d0:	84ce                	mv	s1,s3
  d2:	bff9                	j	b0 <readline+0x7e>
    int i = 0;
  d4:	4481                	li	s1,0
  d6:	bfe9                	j	b0 <readline+0x7e>

00000000000000d8 <main>:

int main(int argc, char *argv[])
{
  d8:	cd010113          	addi	sp,sp,-816
  dc:	32113423          	sd	ra,808(sp)
  e0:	32813023          	sd	s0,800(sp)
  e4:	30913c23          	sd	s1,792(sp)
  e8:	31213823          	sd	s2,784(sp)
  ec:	31313423          	sd	s3,776(sp)
  f0:	31413023          	sd	s4,768(sp)
  f4:	1e00                	addi	s0,sp,816
    if (argc < 2)
  f6:	4785                	li	a5,1
  f8:	08a7d863          	bge	a5,a0,188 <main+0xb0>
    {
        fprintf(2, "xargs: missing command\n");
        exit(1);
    }
    if (argc - 1 >= MAXARG)
  fc:	02000793          	li	a5,32
 100:	0aa7c263          	blt	a5,a0,1a4 <main+0xcc>
 104:	05a1                	addi	a1,a1,8
 106:	cd040793          	addi	a5,s0,-816
 10a:	ffe5069b          	addiw	a3,a0,-2
 10e:	1682                	slli	a3,a3,0x20
 110:	9281                	srli	a3,a3,0x20
 112:	068e                	slli	a3,a3,0x3
 114:	cd840713          	addi	a4,s0,-808
 118:	96ba                	add	a3,a3,a4
    char *x_argv[MAXARG];

    // 复制原始参数 (跳过 "xargs")
    for (int i = 1; i < argc; ++i)
    {
        x_argv[i - 1] = argv[i];
 11a:	6198                	ld	a4,0(a1)
 11c:	e398                	sd	a4,0(a5)
    for (int i = 1; i < argc; ++i)
 11e:	05a1                	addi	a1,a1,8
 120:	07a1                	addi	a5,a5,8
 122:	fed79ce3          	bne	a5,a3,11a <main+0x42>
    }
    int base_argc = argc - 1;
 126:	fff5091b          	addiw	s2,a0,-1
            break; // EOF
        if (buf[0] == '\0')
            continue; // 跳过空行

        // 添加整行作为单个参数
        if (base_argc >= MAXARG - 1)
 12a:	4a79                	li	s4,30
        {
            fprintf(2, "xargs: too many arguments.\n");
            exit(1);
        }
        x_argv[base_argc] = buf;
 12c:	00391993          	slli	s3,s2,0x3
 130:	fd040793          	addi	a5,s0,-48
 134:	99be                	add	s3,s3,a5
        x_argv[base_argc + 1] = 0; // 终止参数数组
 136:	050e                	slli	a0,a0,0x3
 138:	00a784b3          	add	s1,a5,a0
        int n = readline(buf, MAXSZ);
 13c:	20000593          	li	a1,512
 140:	dd040513          	addi	a0,s0,-560
 144:	00000097          	auipc	ra,0x0
 148:	eee080e7          	jalr	-274(ra) # 32 <readline>
        if (n == 0)
 14c:	c161                	beqz	a0,20c <main+0x134>
        if (buf[0] == '\0')
 14e:	dd044783          	lbu	a5,-560(s0)
 152:	d7ed                	beqz	a5,13c <main+0x64>
        if (base_argc >= MAXARG - 1)
 154:	072a4663          	blt	s4,s2,1c0 <main+0xe8>
        x_argv[base_argc] = buf;
 158:	dd040793          	addi	a5,s0,-560
 15c:	d0f9b023          	sd	a5,-768(s3)
        x_argv[base_argc + 1] = 0; // 终止参数数组
 160:	d004b023          	sd	zero,-768(s1)

        if (fork() == 0)
 164:	00000097          	auipc	ra,0x0
 168:	320080e7          	jalr	800(ra) # 484 <fork>
 16c:	c925                	beqz	a0,1dc <main+0x104>
        {
            exec(x_argv[0], x_argv);
            fprintf(2, "xargs: exec %s failed\n", x_argv[0]);
            exit(1);
        }
        wait(0);
 16e:	4501                	li	a0,0
 170:	00000097          	auipc	ra,0x0
 174:	324080e7          	jalr	804(ra) # 494 <wait>
        clearArgv(x_argv, base_argc);
 178:	85ca                	mv	a1,s2
 17a:	cd040513          	addi	a0,s0,-816
 17e:	00000097          	auipc	ra,0x0
 182:	e82080e7          	jalr	-382(ra) # 0 <clearArgv>
 186:	bf5d                	j	13c <main+0x64>
        fprintf(2, "xargs: missing command\n");
 188:	00001597          	auipc	a1,0x1
 18c:	82058593          	addi	a1,a1,-2016 # 9a8 <malloc+0xe6>
 190:	4509                	li	a0,2
 192:	00000097          	auipc	ra,0x0
 196:	644080e7          	jalr	1604(ra) # 7d6 <fprintf>
        exit(1);
 19a:	4505                	li	a0,1
 19c:	00000097          	auipc	ra,0x0
 1a0:	2f0080e7          	jalr	752(ra) # 48c <exit>
        fprintf(2, "xargs: too many arguments.\n");
 1a4:	00001597          	auipc	a1,0x1
 1a8:	81c58593          	addi	a1,a1,-2020 # 9c0 <malloc+0xfe>
 1ac:	4509                	li	a0,2
 1ae:	00000097          	auipc	ra,0x0
 1b2:	628080e7          	jalr	1576(ra) # 7d6 <fprintf>
        exit(1);
 1b6:	4505                	li	a0,1
 1b8:	00000097          	auipc	ra,0x0
 1bc:	2d4080e7          	jalr	724(ra) # 48c <exit>
            fprintf(2, "xargs: too many arguments.\n");
 1c0:	00001597          	auipc	a1,0x1
 1c4:	80058593          	addi	a1,a1,-2048 # 9c0 <malloc+0xfe>
 1c8:	4509                	li	a0,2
 1ca:	00000097          	auipc	ra,0x0
 1ce:	60c080e7          	jalr	1548(ra) # 7d6 <fprintf>
            exit(1);
 1d2:	4505                	li	a0,1
 1d4:	00000097          	auipc	ra,0x0
 1d8:	2b8080e7          	jalr	696(ra) # 48c <exit>
            exec(x_argv[0], x_argv);
 1dc:	cd040593          	addi	a1,s0,-816
 1e0:	cd043503          	ld	a0,-816(s0)
 1e4:	00000097          	auipc	ra,0x0
 1e8:	2e0080e7          	jalr	736(ra) # 4c4 <exec>
            fprintf(2, "xargs: exec %s failed\n", x_argv[0]);
 1ec:	cd043603          	ld	a2,-816(s0)
 1f0:	00000597          	auipc	a1,0x0
 1f4:	7f058593          	addi	a1,a1,2032 # 9e0 <malloc+0x11e>
 1f8:	4509                	li	a0,2
 1fa:	00000097          	auipc	ra,0x0
 1fe:	5dc080e7          	jalr	1500(ra) # 7d6 <fprintf>
            exit(1);
 202:	4505                	li	a0,1
 204:	00000097          	auipc	ra,0x0
 208:	288080e7          	jalr	648(ra) # 48c <exit>
    }
    exit(0);
 20c:	4501                	li	a0,0
 20e:	00000097          	auipc	ra,0x0
 212:	27e080e7          	jalr	638(ra) # 48c <exit>

0000000000000216 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 216:	1141                	addi	sp,sp,-16
 218:	e422                	sd	s0,8(sp)
 21a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 21c:	87aa                	mv	a5,a0
 21e:	0585                	addi	a1,a1,1
 220:	0785                	addi	a5,a5,1
 222:	fff5c703          	lbu	a4,-1(a1)
 226:	fee78fa3          	sb	a4,-1(a5)
 22a:	fb75                	bnez	a4,21e <strcpy+0x8>
    ;
  return os;
}
 22c:	6422                	ld	s0,8(sp)
 22e:	0141                	addi	sp,sp,16
 230:	8082                	ret

0000000000000232 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 232:	1141                	addi	sp,sp,-16
 234:	e422                	sd	s0,8(sp)
 236:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 238:	00054783          	lbu	a5,0(a0)
 23c:	cb91                	beqz	a5,250 <strcmp+0x1e>
 23e:	0005c703          	lbu	a4,0(a1)
 242:	00f71763          	bne	a4,a5,250 <strcmp+0x1e>
    p++, q++;
 246:	0505                	addi	a0,a0,1
 248:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 24a:	00054783          	lbu	a5,0(a0)
 24e:	fbe5                	bnez	a5,23e <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 250:	0005c503          	lbu	a0,0(a1)
}
 254:	40a7853b          	subw	a0,a5,a0
 258:	6422                	ld	s0,8(sp)
 25a:	0141                	addi	sp,sp,16
 25c:	8082                	ret

000000000000025e <strlen>:

uint
strlen(const char *s)
{
 25e:	1141                	addi	sp,sp,-16
 260:	e422                	sd	s0,8(sp)
 262:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 264:	00054783          	lbu	a5,0(a0)
 268:	cf91                	beqz	a5,284 <strlen+0x26>
 26a:	0505                	addi	a0,a0,1
 26c:	87aa                	mv	a5,a0
 26e:	4685                	li	a3,1
 270:	9e89                	subw	a3,a3,a0
 272:	00f6853b          	addw	a0,a3,a5
 276:	0785                	addi	a5,a5,1
 278:	fff7c703          	lbu	a4,-1(a5)
 27c:	fb7d                	bnez	a4,272 <strlen+0x14>
    ;
  return n;
}
 27e:	6422                	ld	s0,8(sp)
 280:	0141                	addi	sp,sp,16
 282:	8082                	ret
  for(n = 0; s[n]; n++)
 284:	4501                	li	a0,0
 286:	bfe5                	j	27e <strlen+0x20>

0000000000000288 <memset>:

void*
memset(void *dst, int c, uint n)
{
 288:	1141                	addi	sp,sp,-16
 28a:	e422                	sd	s0,8(sp)
 28c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 28e:	ce09                	beqz	a2,2a8 <memset+0x20>
 290:	87aa                	mv	a5,a0
 292:	fff6071b          	addiw	a4,a2,-1
 296:	1702                	slli	a4,a4,0x20
 298:	9301                	srli	a4,a4,0x20
 29a:	0705                	addi	a4,a4,1
 29c:	972a                	add	a4,a4,a0
    cdst[i] = c;
 29e:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 2a2:	0785                	addi	a5,a5,1
 2a4:	fee79de3          	bne	a5,a4,29e <memset+0x16>
  }
  return dst;
}
 2a8:	6422                	ld	s0,8(sp)
 2aa:	0141                	addi	sp,sp,16
 2ac:	8082                	ret

00000000000002ae <strchr>:

char*
strchr(const char *s, char c)
{
 2ae:	1141                	addi	sp,sp,-16
 2b0:	e422                	sd	s0,8(sp)
 2b2:	0800                	addi	s0,sp,16
  for(; *s; s++)
 2b4:	00054783          	lbu	a5,0(a0)
 2b8:	cb99                	beqz	a5,2ce <strchr+0x20>
    if(*s == c)
 2ba:	00f58763          	beq	a1,a5,2c8 <strchr+0x1a>
  for(; *s; s++)
 2be:	0505                	addi	a0,a0,1
 2c0:	00054783          	lbu	a5,0(a0)
 2c4:	fbfd                	bnez	a5,2ba <strchr+0xc>
      return (char*)s;
  return 0;
 2c6:	4501                	li	a0,0
}
 2c8:	6422                	ld	s0,8(sp)
 2ca:	0141                	addi	sp,sp,16
 2cc:	8082                	ret
  return 0;
 2ce:	4501                	li	a0,0
 2d0:	bfe5                	j	2c8 <strchr+0x1a>

00000000000002d2 <gets>:

char*
gets(char *buf, int max)
{
 2d2:	711d                	addi	sp,sp,-96
 2d4:	ec86                	sd	ra,88(sp)
 2d6:	e8a2                	sd	s0,80(sp)
 2d8:	e4a6                	sd	s1,72(sp)
 2da:	e0ca                	sd	s2,64(sp)
 2dc:	fc4e                	sd	s3,56(sp)
 2de:	f852                	sd	s4,48(sp)
 2e0:	f456                	sd	s5,40(sp)
 2e2:	f05a                	sd	s6,32(sp)
 2e4:	ec5e                	sd	s7,24(sp)
 2e6:	1080                	addi	s0,sp,96
 2e8:	8baa                	mv	s7,a0
 2ea:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2ec:	892a                	mv	s2,a0
 2ee:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 2f0:	4aa9                	li	s5,10
 2f2:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 2f4:	89a6                	mv	s3,s1
 2f6:	2485                	addiw	s1,s1,1
 2f8:	0344d863          	bge	s1,s4,328 <gets+0x56>
    cc = read(0, &c, 1);
 2fc:	4605                	li	a2,1
 2fe:	faf40593          	addi	a1,s0,-81
 302:	4501                	li	a0,0
 304:	00000097          	auipc	ra,0x0
 308:	1a0080e7          	jalr	416(ra) # 4a4 <read>
    if(cc < 1)
 30c:	00a05e63          	blez	a0,328 <gets+0x56>
    buf[i++] = c;
 310:	faf44783          	lbu	a5,-81(s0)
 314:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 318:	01578763          	beq	a5,s5,326 <gets+0x54>
 31c:	0905                	addi	s2,s2,1
 31e:	fd679be3          	bne	a5,s6,2f4 <gets+0x22>
  for(i=0; i+1 < max; ){
 322:	89a6                	mv	s3,s1
 324:	a011                	j	328 <gets+0x56>
 326:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 328:	99de                	add	s3,s3,s7
 32a:	00098023          	sb	zero,0(s3)
  return buf;
}
 32e:	855e                	mv	a0,s7
 330:	60e6                	ld	ra,88(sp)
 332:	6446                	ld	s0,80(sp)
 334:	64a6                	ld	s1,72(sp)
 336:	6906                	ld	s2,64(sp)
 338:	79e2                	ld	s3,56(sp)
 33a:	7a42                	ld	s4,48(sp)
 33c:	7aa2                	ld	s5,40(sp)
 33e:	7b02                	ld	s6,32(sp)
 340:	6be2                	ld	s7,24(sp)
 342:	6125                	addi	sp,sp,96
 344:	8082                	ret

0000000000000346 <stat>:

int
stat(const char *n, struct stat *st)
{
 346:	1101                	addi	sp,sp,-32
 348:	ec06                	sd	ra,24(sp)
 34a:	e822                	sd	s0,16(sp)
 34c:	e426                	sd	s1,8(sp)
 34e:	e04a                	sd	s2,0(sp)
 350:	1000                	addi	s0,sp,32
 352:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 354:	4581                	li	a1,0
 356:	00000097          	auipc	ra,0x0
 35a:	176080e7          	jalr	374(ra) # 4cc <open>
  if(fd < 0)
 35e:	02054563          	bltz	a0,388 <stat+0x42>
 362:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 364:	85ca                	mv	a1,s2
 366:	00000097          	auipc	ra,0x0
 36a:	17e080e7          	jalr	382(ra) # 4e4 <fstat>
 36e:	892a                	mv	s2,a0
  close(fd);
 370:	8526                	mv	a0,s1
 372:	00000097          	auipc	ra,0x0
 376:	142080e7          	jalr	322(ra) # 4b4 <close>
  return r;
}
 37a:	854a                	mv	a0,s2
 37c:	60e2                	ld	ra,24(sp)
 37e:	6442                	ld	s0,16(sp)
 380:	64a2                	ld	s1,8(sp)
 382:	6902                	ld	s2,0(sp)
 384:	6105                	addi	sp,sp,32
 386:	8082                	ret
    return -1;
 388:	597d                	li	s2,-1
 38a:	bfc5                	j	37a <stat+0x34>

000000000000038c <atoi>:

int
atoi(const char *s)
{
 38c:	1141                	addi	sp,sp,-16
 38e:	e422                	sd	s0,8(sp)
 390:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 392:	00054603          	lbu	a2,0(a0)
 396:	fd06079b          	addiw	a5,a2,-48
 39a:	0ff7f793          	andi	a5,a5,255
 39e:	4725                	li	a4,9
 3a0:	02f76963          	bltu	a4,a5,3d2 <atoi+0x46>
 3a4:	86aa                	mv	a3,a0
  n = 0;
 3a6:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 3a8:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 3aa:	0685                	addi	a3,a3,1
 3ac:	0025179b          	slliw	a5,a0,0x2
 3b0:	9fa9                	addw	a5,a5,a0
 3b2:	0017979b          	slliw	a5,a5,0x1
 3b6:	9fb1                	addw	a5,a5,a2
 3b8:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 3bc:	0006c603          	lbu	a2,0(a3)
 3c0:	fd06071b          	addiw	a4,a2,-48
 3c4:	0ff77713          	andi	a4,a4,255
 3c8:	fee5f1e3          	bgeu	a1,a4,3aa <atoi+0x1e>
  return n;
}
 3cc:	6422                	ld	s0,8(sp)
 3ce:	0141                	addi	sp,sp,16
 3d0:	8082                	ret
  n = 0;
 3d2:	4501                	li	a0,0
 3d4:	bfe5                	j	3cc <atoi+0x40>

00000000000003d6 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 3d6:	1141                	addi	sp,sp,-16
 3d8:	e422                	sd	s0,8(sp)
 3da:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 3dc:	02b57663          	bgeu	a0,a1,408 <memmove+0x32>
    while(n-- > 0)
 3e0:	02c05163          	blez	a2,402 <memmove+0x2c>
 3e4:	fff6079b          	addiw	a5,a2,-1
 3e8:	1782                	slli	a5,a5,0x20
 3ea:	9381                	srli	a5,a5,0x20
 3ec:	0785                	addi	a5,a5,1
 3ee:	97aa                	add	a5,a5,a0
  dst = vdst;
 3f0:	872a                	mv	a4,a0
      *dst++ = *src++;
 3f2:	0585                	addi	a1,a1,1
 3f4:	0705                	addi	a4,a4,1
 3f6:	fff5c683          	lbu	a3,-1(a1)
 3fa:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 3fe:	fee79ae3          	bne	a5,a4,3f2 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 402:	6422                	ld	s0,8(sp)
 404:	0141                	addi	sp,sp,16
 406:	8082                	ret
    dst += n;
 408:	00c50733          	add	a4,a0,a2
    src += n;
 40c:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 40e:	fec05ae3          	blez	a2,402 <memmove+0x2c>
 412:	fff6079b          	addiw	a5,a2,-1
 416:	1782                	slli	a5,a5,0x20
 418:	9381                	srli	a5,a5,0x20
 41a:	fff7c793          	not	a5,a5
 41e:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 420:	15fd                	addi	a1,a1,-1
 422:	177d                	addi	a4,a4,-1
 424:	0005c683          	lbu	a3,0(a1)
 428:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 42c:	fee79ae3          	bne	a5,a4,420 <memmove+0x4a>
 430:	bfc9                	j	402 <memmove+0x2c>

0000000000000432 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 432:	1141                	addi	sp,sp,-16
 434:	e422                	sd	s0,8(sp)
 436:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 438:	ca05                	beqz	a2,468 <memcmp+0x36>
 43a:	fff6069b          	addiw	a3,a2,-1
 43e:	1682                	slli	a3,a3,0x20
 440:	9281                	srli	a3,a3,0x20
 442:	0685                	addi	a3,a3,1
 444:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 446:	00054783          	lbu	a5,0(a0)
 44a:	0005c703          	lbu	a4,0(a1)
 44e:	00e79863          	bne	a5,a4,45e <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 452:	0505                	addi	a0,a0,1
    p2++;
 454:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 456:	fed518e3          	bne	a0,a3,446 <memcmp+0x14>
  }
  return 0;
 45a:	4501                	li	a0,0
 45c:	a019                	j	462 <memcmp+0x30>
      return *p1 - *p2;
 45e:	40e7853b          	subw	a0,a5,a4
}
 462:	6422                	ld	s0,8(sp)
 464:	0141                	addi	sp,sp,16
 466:	8082                	ret
  return 0;
 468:	4501                	li	a0,0
 46a:	bfe5                	j	462 <memcmp+0x30>

000000000000046c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 46c:	1141                	addi	sp,sp,-16
 46e:	e406                	sd	ra,8(sp)
 470:	e022                	sd	s0,0(sp)
 472:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 474:	00000097          	auipc	ra,0x0
 478:	f62080e7          	jalr	-158(ra) # 3d6 <memmove>
}
 47c:	60a2                	ld	ra,8(sp)
 47e:	6402                	ld	s0,0(sp)
 480:	0141                	addi	sp,sp,16
 482:	8082                	ret

0000000000000484 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 484:	4885                	li	a7,1
 ecall
 486:	00000073          	ecall
 ret
 48a:	8082                	ret

000000000000048c <exit>:
.global exit
exit:
 li a7, SYS_exit
 48c:	4889                	li	a7,2
 ecall
 48e:	00000073          	ecall
 ret
 492:	8082                	ret

0000000000000494 <wait>:
.global wait
wait:
 li a7, SYS_wait
 494:	488d                	li	a7,3
 ecall
 496:	00000073          	ecall
 ret
 49a:	8082                	ret

000000000000049c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 49c:	4891                	li	a7,4
 ecall
 49e:	00000073          	ecall
 ret
 4a2:	8082                	ret

00000000000004a4 <read>:
.global read
read:
 li a7, SYS_read
 4a4:	4895                	li	a7,5
 ecall
 4a6:	00000073          	ecall
 ret
 4aa:	8082                	ret

00000000000004ac <write>:
.global write
write:
 li a7, SYS_write
 4ac:	48c1                	li	a7,16
 ecall
 4ae:	00000073          	ecall
 ret
 4b2:	8082                	ret

00000000000004b4 <close>:
.global close
close:
 li a7, SYS_close
 4b4:	48d5                	li	a7,21
 ecall
 4b6:	00000073          	ecall
 ret
 4ba:	8082                	ret

00000000000004bc <kill>:
.global kill
kill:
 li a7, SYS_kill
 4bc:	4899                	li	a7,6
 ecall
 4be:	00000073          	ecall
 ret
 4c2:	8082                	ret

00000000000004c4 <exec>:
.global exec
exec:
 li a7, SYS_exec
 4c4:	489d                	li	a7,7
 ecall
 4c6:	00000073          	ecall
 ret
 4ca:	8082                	ret

00000000000004cc <open>:
.global open
open:
 li a7, SYS_open
 4cc:	48bd                	li	a7,15
 ecall
 4ce:	00000073          	ecall
 ret
 4d2:	8082                	ret

00000000000004d4 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 4d4:	48c5                	li	a7,17
 ecall
 4d6:	00000073          	ecall
 ret
 4da:	8082                	ret

00000000000004dc <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 4dc:	48c9                	li	a7,18
 ecall
 4de:	00000073          	ecall
 ret
 4e2:	8082                	ret

00000000000004e4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 4e4:	48a1                	li	a7,8
 ecall
 4e6:	00000073          	ecall
 ret
 4ea:	8082                	ret

00000000000004ec <link>:
.global link
link:
 li a7, SYS_link
 4ec:	48cd                	li	a7,19
 ecall
 4ee:	00000073          	ecall
 ret
 4f2:	8082                	ret

00000000000004f4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 4f4:	48d1                	li	a7,20
 ecall
 4f6:	00000073          	ecall
 ret
 4fa:	8082                	ret

00000000000004fc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 4fc:	48a5                	li	a7,9
 ecall
 4fe:	00000073          	ecall
 ret
 502:	8082                	ret

0000000000000504 <dup>:
.global dup
dup:
 li a7, SYS_dup
 504:	48a9                	li	a7,10
 ecall
 506:	00000073          	ecall
 ret
 50a:	8082                	ret

000000000000050c <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 50c:	48ad                	li	a7,11
 ecall
 50e:	00000073          	ecall
 ret
 512:	8082                	ret

0000000000000514 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 514:	48b1                	li	a7,12
 ecall
 516:	00000073          	ecall
 ret
 51a:	8082                	ret

000000000000051c <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 51c:	48b5                	li	a7,13
 ecall
 51e:	00000073          	ecall
 ret
 522:	8082                	ret

0000000000000524 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 524:	48b9                	li	a7,14
 ecall
 526:	00000073          	ecall
 ret
 52a:	8082                	ret

000000000000052c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 52c:	1101                	addi	sp,sp,-32
 52e:	ec06                	sd	ra,24(sp)
 530:	e822                	sd	s0,16(sp)
 532:	1000                	addi	s0,sp,32
 534:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 538:	4605                	li	a2,1
 53a:	fef40593          	addi	a1,s0,-17
 53e:	00000097          	auipc	ra,0x0
 542:	f6e080e7          	jalr	-146(ra) # 4ac <write>
}
 546:	60e2                	ld	ra,24(sp)
 548:	6442                	ld	s0,16(sp)
 54a:	6105                	addi	sp,sp,32
 54c:	8082                	ret

000000000000054e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 54e:	7139                	addi	sp,sp,-64
 550:	fc06                	sd	ra,56(sp)
 552:	f822                	sd	s0,48(sp)
 554:	f426                	sd	s1,40(sp)
 556:	f04a                	sd	s2,32(sp)
 558:	ec4e                	sd	s3,24(sp)
 55a:	0080                	addi	s0,sp,64
 55c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 55e:	c299                	beqz	a3,564 <printint+0x16>
 560:	0805c863          	bltz	a1,5f0 <printint+0xa2>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 564:	2581                	sext.w	a1,a1
  neg = 0;
 566:	4881                	li	a7,0
 568:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 56c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 56e:	2601                	sext.w	a2,a2
 570:	00000517          	auipc	a0,0x0
 574:	49050513          	addi	a0,a0,1168 # a00 <digits>
 578:	883a                	mv	a6,a4
 57a:	2705                	addiw	a4,a4,1
 57c:	02c5f7bb          	remuw	a5,a1,a2
 580:	1782                	slli	a5,a5,0x20
 582:	9381                	srli	a5,a5,0x20
 584:	97aa                	add	a5,a5,a0
 586:	0007c783          	lbu	a5,0(a5)
 58a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 58e:	0005879b          	sext.w	a5,a1
 592:	02c5d5bb          	divuw	a1,a1,a2
 596:	0685                	addi	a3,a3,1
 598:	fec7f0e3          	bgeu	a5,a2,578 <printint+0x2a>
  if(neg)
 59c:	00088b63          	beqz	a7,5b2 <printint+0x64>
    buf[i++] = '-';
 5a0:	fd040793          	addi	a5,s0,-48
 5a4:	973e                	add	a4,a4,a5
 5a6:	02d00793          	li	a5,45
 5aa:	fef70823          	sb	a5,-16(a4)
 5ae:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 5b2:	02e05863          	blez	a4,5e2 <printint+0x94>
 5b6:	fc040793          	addi	a5,s0,-64
 5ba:	00e78933          	add	s2,a5,a4
 5be:	fff78993          	addi	s3,a5,-1
 5c2:	99ba                	add	s3,s3,a4
 5c4:	377d                	addiw	a4,a4,-1
 5c6:	1702                	slli	a4,a4,0x20
 5c8:	9301                	srli	a4,a4,0x20
 5ca:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 5ce:	fff94583          	lbu	a1,-1(s2)
 5d2:	8526                	mv	a0,s1
 5d4:	00000097          	auipc	ra,0x0
 5d8:	f58080e7          	jalr	-168(ra) # 52c <putc>
  while(--i >= 0)
 5dc:	197d                	addi	s2,s2,-1
 5de:	ff3918e3          	bne	s2,s3,5ce <printint+0x80>
}
 5e2:	70e2                	ld	ra,56(sp)
 5e4:	7442                	ld	s0,48(sp)
 5e6:	74a2                	ld	s1,40(sp)
 5e8:	7902                	ld	s2,32(sp)
 5ea:	69e2                	ld	s3,24(sp)
 5ec:	6121                	addi	sp,sp,64
 5ee:	8082                	ret
    x = -xx;
 5f0:	40b005bb          	negw	a1,a1
    neg = 1;
 5f4:	4885                	li	a7,1
    x = -xx;
 5f6:	bf8d                	j	568 <printint+0x1a>

00000000000005f8 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 5f8:	7119                	addi	sp,sp,-128
 5fa:	fc86                	sd	ra,120(sp)
 5fc:	f8a2                	sd	s0,112(sp)
 5fe:	f4a6                	sd	s1,104(sp)
 600:	f0ca                	sd	s2,96(sp)
 602:	ecce                	sd	s3,88(sp)
 604:	e8d2                	sd	s4,80(sp)
 606:	e4d6                	sd	s5,72(sp)
 608:	e0da                	sd	s6,64(sp)
 60a:	fc5e                	sd	s7,56(sp)
 60c:	f862                	sd	s8,48(sp)
 60e:	f466                	sd	s9,40(sp)
 610:	f06a                	sd	s10,32(sp)
 612:	ec6e                	sd	s11,24(sp)
 614:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 616:	0005c903          	lbu	s2,0(a1)
 61a:	18090f63          	beqz	s2,7b8 <vprintf+0x1c0>
 61e:	8aaa                	mv	s5,a0
 620:	8b32                	mv	s6,a2
 622:	00158493          	addi	s1,a1,1
  state = 0;
 626:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 628:	02500a13          	li	s4,37
      if(c == 'd'){
 62c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 630:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 634:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 638:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 63c:	00000b97          	auipc	s7,0x0
 640:	3c4b8b93          	addi	s7,s7,964 # a00 <digits>
 644:	a839                	j	662 <vprintf+0x6a>
        putc(fd, c);
 646:	85ca                	mv	a1,s2
 648:	8556                	mv	a0,s5
 64a:	00000097          	auipc	ra,0x0
 64e:	ee2080e7          	jalr	-286(ra) # 52c <putc>
 652:	a019                	j	658 <vprintf+0x60>
    } else if(state == '%'){
 654:	01498f63          	beq	s3,s4,672 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 658:	0485                	addi	s1,s1,1
 65a:	fff4c903          	lbu	s2,-1(s1)
 65e:	14090d63          	beqz	s2,7b8 <vprintf+0x1c0>
    c = fmt[i] & 0xff;
 662:	0009079b          	sext.w	a5,s2
    if(state == 0){
 666:	fe0997e3          	bnez	s3,654 <vprintf+0x5c>
      if(c == '%'){
 66a:	fd479ee3          	bne	a5,s4,646 <vprintf+0x4e>
        state = '%';
 66e:	89be                	mv	s3,a5
 670:	b7e5                	j	658 <vprintf+0x60>
      if(c == 'd'){
 672:	05878063          	beq	a5,s8,6b2 <vprintf+0xba>
      } else if(c == 'l') {
 676:	05978c63          	beq	a5,s9,6ce <vprintf+0xd6>
      } else if(c == 'x') {
 67a:	07a78863          	beq	a5,s10,6ea <vprintf+0xf2>
      } else if(c == 'p') {
 67e:	09b78463          	beq	a5,s11,706 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 682:	07300713          	li	a4,115
 686:	0ce78663          	beq	a5,a4,752 <vprintf+0x15a>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 68a:	06300713          	li	a4,99
 68e:	0ee78e63          	beq	a5,a4,78a <vprintf+0x192>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 692:	11478863          	beq	a5,s4,7a2 <vprintf+0x1aa>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 696:	85d2                	mv	a1,s4
 698:	8556                	mv	a0,s5
 69a:	00000097          	auipc	ra,0x0
 69e:	e92080e7          	jalr	-366(ra) # 52c <putc>
        putc(fd, c);
 6a2:	85ca                	mv	a1,s2
 6a4:	8556                	mv	a0,s5
 6a6:	00000097          	auipc	ra,0x0
 6aa:	e86080e7          	jalr	-378(ra) # 52c <putc>
      }
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	b765                	j	658 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 6b2:	008b0913          	addi	s2,s6,8
 6b6:	4685                	li	a3,1
 6b8:	4629                	li	a2,10
 6ba:	000b2583          	lw	a1,0(s6)
 6be:	8556                	mv	a0,s5
 6c0:	00000097          	auipc	ra,0x0
 6c4:	e8e080e7          	jalr	-370(ra) # 54e <printint>
 6c8:	8b4a                	mv	s6,s2
      state = 0;
 6ca:	4981                	li	s3,0
 6cc:	b771                	j	658 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 6ce:	008b0913          	addi	s2,s6,8
 6d2:	4681                	li	a3,0
 6d4:	4629                	li	a2,10
 6d6:	000b2583          	lw	a1,0(s6)
 6da:	8556                	mv	a0,s5
 6dc:	00000097          	auipc	ra,0x0
 6e0:	e72080e7          	jalr	-398(ra) # 54e <printint>
 6e4:	8b4a                	mv	s6,s2
      state = 0;
 6e6:	4981                	li	s3,0
 6e8:	bf85                	j	658 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 6ea:	008b0913          	addi	s2,s6,8
 6ee:	4681                	li	a3,0
 6f0:	4641                	li	a2,16
 6f2:	000b2583          	lw	a1,0(s6)
 6f6:	8556                	mv	a0,s5
 6f8:	00000097          	auipc	ra,0x0
 6fc:	e56080e7          	jalr	-426(ra) # 54e <printint>
 700:	8b4a                	mv	s6,s2
      state = 0;
 702:	4981                	li	s3,0
 704:	bf91                	j	658 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 706:	008b0793          	addi	a5,s6,8
 70a:	f8f43423          	sd	a5,-120(s0)
 70e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 712:	03000593          	li	a1,48
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	e14080e7          	jalr	-492(ra) # 52c <putc>
  putc(fd, 'x');
 720:	85ea                	mv	a1,s10
 722:	8556                	mv	a0,s5
 724:	00000097          	auipc	ra,0x0
 728:	e08080e7          	jalr	-504(ra) # 52c <putc>
 72c:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 72e:	03c9d793          	srli	a5,s3,0x3c
 732:	97de                	add	a5,a5,s7
 734:	0007c583          	lbu	a1,0(a5)
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	df2080e7          	jalr	-526(ra) # 52c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 742:	0992                	slli	s3,s3,0x4
 744:	397d                	addiw	s2,s2,-1
 746:	fe0914e3          	bnez	s2,72e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 74a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 74e:	4981                	li	s3,0
 750:	b721                	j	658 <vprintf+0x60>
        s = va_arg(ap, char*);
 752:	008b0993          	addi	s3,s6,8
 756:	000b3903          	ld	s2,0(s6)
        if(s == 0)
 75a:	02090163          	beqz	s2,77c <vprintf+0x184>
        while(*s != 0){
 75e:	00094583          	lbu	a1,0(s2)
 762:	c9a1                	beqz	a1,7b2 <vprintf+0x1ba>
          putc(fd, *s);
 764:	8556                	mv	a0,s5
 766:	00000097          	auipc	ra,0x0
 76a:	dc6080e7          	jalr	-570(ra) # 52c <putc>
          s++;
 76e:	0905                	addi	s2,s2,1
        while(*s != 0){
 770:	00094583          	lbu	a1,0(s2)
 774:	f9e5                	bnez	a1,764 <vprintf+0x16c>
        s = va_arg(ap, char*);
 776:	8b4e                	mv	s6,s3
      state = 0;
 778:	4981                	li	s3,0
 77a:	bdf9                	j	658 <vprintf+0x60>
          s = "(null)";
 77c:	00000917          	auipc	s2,0x0
 780:	27c90913          	addi	s2,s2,636 # 9f8 <malloc+0x136>
        while(*s != 0){
 784:	02800593          	li	a1,40
 788:	bff1                	j	764 <vprintf+0x16c>
        putc(fd, va_arg(ap, uint));
 78a:	008b0913          	addi	s2,s6,8
 78e:	000b4583          	lbu	a1,0(s6)
 792:	8556                	mv	a0,s5
 794:	00000097          	auipc	ra,0x0
 798:	d98080e7          	jalr	-616(ra) # 52c <putc>
 79c:	8b4a                	mv	s6,s2
      state = 0;
 79e:	4981                	li	s3,0
 7a0:	bd65                	j	658 <vprintf+0x60>
        putc(fd, c);
 7a2:	85d2                	mv	a1,s4
 7a4:	8556                	mv	a0,s5
 7a6:	00000097          	auipc	ra,0x0
 7aa:	d86080e7          	jalr	-634(ra) # 52c <putc>
      state = 0;
 7ae:	4981                	li	s3,0
 7b0:	b565                	j	658 <vprintf+0x60>
        s = va_arg(ap, char*);
 7b2:	8b4e                	mv	s6,s3
      state = 0;
 7b4:	4981                	li	s3,0
 7b6:	b54d                	j	658 <vprintf+0x60>
    }
  }
}
 7b8:	70e6                	ld	ra,120(sp)
 7ba:	7446                	ld	s0,112(sp)
 7bc:	74a6                	ld	s1,104(sp)
 7be:	7906                	ld	s2,96(sp)
 7c0:	69e6                	ld	s3,88(sp)
 7c2:	6a46                	ld	s4,80(sp)
 7c4:	6aa6                	ld	s5,72(sp)
 7c6:	6b06                	ld	s6,64(sp)
 7c8:	7be2                	ld	s7,56(sp)
 7ca:	7c42                	ld	s8,48(sp)
 7cc:	7ca2                	ld	s9,40(sp)
 7ce:	7d02                	ld	s10,32(sp)
 7d0:	6de2                	ld	s11,24(sp)
 7d2:	6109                	addi	sp,sp,128
 7d4:	8082                	ret

00000000000007d6 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 7d6:	715d                	addi	sp,sp,-80
 7d8:	ec06                	sd	ra,24(sp)
 7da:	e822                	sd	s0,16(sp)
 7dc:	1000                	addi	s0,sp,32
 7de:	e010                	sd	a2,0(s0)
 7e0:	e414                	sd	a3,8(s0)
 7e2:	e818                	sd	a4,16(s0)
 7e4:	ec1c                	sd	a5,24(s0)
 7e6:	03043023          	sd	a6,32(s0)
 7ea:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 7ee:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 7f2:	8622                	mv	a2,s0
 7f4:	00000097          	auipc	ra,0x0
 7f8:	e04080e7          	jalr	-508(ra) # 5f8 <vprintf>
}
 7fc:	60e2                	ld	ra,24(sp)
 7fe:	6442                	ld	s0,16(sp)
 800:	6161                	addi	sp,sp,80
 802:	8082                	ret

0000000000000804 <printf>:

void
printf(const char *fmt, ...)
{
 804:	711d                	addi	sp,sp,-96
 806:	ec06                	sd	ra,24(sp)
 808:	e822                	sd	s0,16(sp)
 80a:	1000                	addi	s0,sp,32
 80c:	e40c                	sd	a1,8(s0)
 80e:	e810                	sd	a2,16(s0)
 810:	ec14                	sd	a3,24(s0)
 812:	f018                	sd	a4,32(s0)
 814:	f41c                	sd	a5,40(s0)
 816:	03043823          	sd	a6,48(s0)
 81a:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 81e:	00840613          	addi	a2,s0,8
 822:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 826:	85aa                	mv	a1,a0
 828:	4505                	li	a0,1
 82a:	00000097          	auipc	ra,0x0
 82e:	dce080e7          	jalr	-562(ra) # 5f8 <vprintf>
}
 832:	60e2                	ld	ra,24(sp)
 834:	6442                	ld	s0,16(sp)
 836:	6125                	addi	sp,sp,96
 838:	8082                	ret

000000000000083a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 83a:	1141                	addi	sp,sp,-16
 83c:	e422                	sd	s0,8(sp)
 83e:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 840:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 844:	00000797          	auipc	a5,0x0
 848:	1d47b783          	ld	a5,468(a5) # a18 <freep>
 84c:	a805                	j	87c <free+0x42>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 84e:	4618                	lw	a4,8(a2)
 850:	9db9                	addw	a1,a1,a4
 852:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 856:	6398                	ld	a4,0(a5)
 858:	6318                	ld	a4,0(a4)
 85a:	fee53823          	sd	a4,-16(a0)
 85e:	a091                	j	8a2 <free+0x68>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 860:	ff852703          	lw	a4,-8(a0)
 864:	9e39                	addw	a2,a2,a4
 866:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 868:	ff053703          	ld	a4,-16(a0)
 86c:	e398                	sd	a4,0(a5)
 86e:	a099                	j	8b4 <free+0x7a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 870:	6398                	ld	a4,0(a5)
 872:	00e7e463          	bltu	a5,a4,87a <free+0x40>
 876:	00e6ea63          	bltu	a3,a4,88a <free+0x50>
{
 87a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 87c:	fed7fae3          	bgeu	a5,a3,870 <free+0x36>
 880:	6398                	ld	a4,0(a5)
 882:	00e6e463          	bltu	a3,a4,88a <free+0x50>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 886:	fee7eae3          	bltu	a5,a4,87a <free+0x40>
  if(bp + bp->s.size == p->s.ptr){
 88a:	ff852583          	lw	a1,-8(a0)
 88e:	6390                	ld	a2,0(a5)
 890:	02059713          	slli	a4,a1,0x20
 894:	9301                	srli	a4,a4,0x20
 896:	0712                	slli	a4,a4,0x4
 898:	9736                	add	a4,a4,a3
 89a:	fae60ae3          	beq	a2,a4,84e <free+0x14>
    bp->s.ptr = p->s.ptr;
 89e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 8a2:	4790                	lw	a2,8(a5)
 8a4:	02061713          	slli	a4,a2,0x20
 8a8:	9301                	srli	a4,a4,0x20
 8aa:	0712                	slli	a4,a4,0x4
 8ac:	973e                	add	a4,a4,a5
 8ae:	fae689e3          	beq	a3,a4,860 <free+0x26>
  } else
    p->s.ptr = bp;
 8b2:	e394                	sd	a3,0(a5)
  freep = p;
 8b4:	00000717          	auipc	a4,0x0
 8b8:	16f73223          	sd	a5,356(a4) # a18 <freep>
}
 8bc:	6422                	ld	s0,8(sp)
 8be:	0141                	addi	sp,sp,16
 8c0:	8082                	ret

00000000000008c2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 8c2:	7139                	addi	sp,sp,-64
 8c4:	fc06                	sd	ra,56(sp)
 8c6:	f822                	sd	s0,48(sp)
 8c8:	f426                	sd	s1,40(sp)
 8ca:	f04a                	sd	s2,32(sp)
 8cc:	ec4e                	sd	s3,24(sp)
 8ce:	e852                	sd	s4,16(sp)
 8d0:	e456                	sd	s5,8(sp)
 8d2:	e05a                	sd	s6,0(sp)
 8d4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 8d6:	02051493          	slli	s1,a0,0x20
 8da:	9081                	srli	s1,s1,0x20
 8dc:	04bd                	addi	s1,s1,15
 8de:	8091                	srli	s1,s1,0x4
 8e0:	0014899b          	addiw	s3,s1,1
 8e4:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 8e6:	00000517          	auipc	a0,0x0
 8ea:	13253503          	ld	a0,306(a0) # a18 <freep>
 8ee:	c515                	beqz	a0,91a <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8f0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8f2:	4798                	lw	a4,8(a5)
 8f4:	02977f63          	bgeu	a4,s1,932 <malloc+0x70>
 8f8:	8a4e                	mv	s4,s3
 8fa:	0009871b          	sext.w	a4,s3
 8fe:	6685                	lui	a3,0x1
 900:	00d77363          	bgeu	a4,a3,906 <malloc+0x44>
 904:	6a05                	lui	s4,0x1
 906:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 90a:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 90e:	00000917          	auipc	s2,0x0
 912:	10a90913          	addi	s2,s2,266 # a18 <freep>
  if(p == (char*)-1)
 916:	5afd                	li	s5,-1
 918:	a88d                	j	98a <malloc+0xc8>
    base.s.ptr = freep = prevp = &base;
 91a:	00000797          	auipc	a5,0x0
 91e:	10678793          	addi	a5,a5,262 # a20 <base>
 922:	00000717          	auipc	a4,0x0
 926:	0ef73b23          	sd	a5,246(a4) # a18 <freep>
 92a:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 92c:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 930:	b7e1                	j	8f8 <malloc+0x36>
      if(p->s.size == nunits)
 932:	02e48b63          	beq	s1,a4,968 <malloc+0xa6>
        p->s.size -= nunits;
 936:	4137073b          	subw	a4,a4,s3
 93a:	c798                	sw	a4,8(a5)
        p += p->s.size;
 93c:	1702                	slli	a4,a4,0x20
 93e:	9301                	srli	a4,a4,0x20
 940:	0712                	slli	a4,a4,0x4
 942:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 944:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 948:	00000717          	auipc	a4,0x0
 94c:	0ca73823          	sd	a0,208(a4) # a18 <freep>
      return (void*)(p + 1);
 950:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 954:	70e2                	ld	ra,56(sp)
 956:	7442                	ld	s0,48(sp)
 958:	74a2                	ld	s1,40(sp)
 95a:	7902                	ld	s2,32(sp)
 95c:	69e2                	ld	s3,24(sp)
 95e:	6a42                	ld	s4,16(sp)
 960:	6aa2                	ld	s5,8(sp)
 962:	6b02                	ld	s6,0(sp)
 964:	6121                	addi	sp,sp,64
 966:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 968:	6398                	ld	a4,0(a5)
 96a:	e118                	sd	a4,0(a0)
 96c:	bff1                	j	948 <malloc+0x86>
  hp->s.size = nu;
 96e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 972:	0541                	addi	a0,a0,16
 974:	00000097          	auipc	ra,0x0
 978:	ec6080e7          	jalr	-314(ra) # 83a <free>
  return freep;
 97c:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 980:	d971                	beqz	a0,954 <malloc+0x92>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 982:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 984:	4798                	lw	a4,8(a5)
 986:	fa9776e3          	bgeu	a4,s1,932 <malloc+0x70>
    if(p == freep)
 98a:	00093703          	ld	a4,0(s2)
 98e:	853e                	mv	a0,a5
 990:	fef719e3          	bne	a4,a5,982 <malloc+0xc0>
  p = sbrk(nu * sizeof(Header));
 994:	8552                	mv	a0,s4
 996:	00000097          	auipc	ra,0x0
 99a:	b7e080e7          	jalr	-1154(ra) # 514 <sbrk>
  if(p == (char*)-1)
 99e:	fd5518e3          	bne	a0,s5,96e <malloc+0xac>
        return 0;
 9a2:	4501                	li	a0,0
 9a4:	bf45                	j	954 <malloc+0x92>
