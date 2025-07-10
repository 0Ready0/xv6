#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/param.h"
#include "kernel/fs.h"
#include "user/user.h"

#define MSGSIZE 16

// // echo hello | xargs echo bye
// // echo hello默认情况下为标准输出，但是由于管道存在，将输出进行重定向
// // | 将左侧的标准输出重定向为标准输入
// int main(int argc, char **argv){    // argv 只包含命令行参数，不包含标准输入/输出内容!!!
//     char buf[MSGSIZE];
//     read(0, buf, MSGSIZE);  
//     printf("获取标准化输入：%s\n", buf);

//     for (int i = 0; i < argc; ++i){
//         printf("argv[%d]: %s\n", i, argv[i]);
//     }

//     exec("echo", argv);

//     exit(0);
// }

#include "kernel/types.h"
#include "user/user.h"
#include "kernel/param.h"

#define MAXSZ 512

void clearArgv(char *x_argv[MAXARG], int beg)
{
    for (int i = beg; i < MAXARG; ++i)
        x_argv[i] = 0;
}

int readline(char *buf, int max)
{
    int i = 0;
    char c;
    while (i < max - 1)
    {
        int n = read(0, &c, 1);
        if (n <= 0)
            break; // EOF or error
        if (c == '\\')
        {
            // 处理转义序列
            n = read(0, &c, 1);
            if (n <= 0)
                break;
            if (c == 'n')
                c = '\n'; // 将 \n 转换为换行符
            // 其他转义序列可在此扩展
        }
        if (c == '\n')
            break; // 遇到换行符结束行
        buf[i++] = c;
    }
    buf[i] = '\0';
    return i;
}

int main(int argc, char *argv[])
{
    if (argc < 2)
    {
        fprintf(2, "xargs: missing command\n");
        exit(1);
    }
    if (argc - 1 >= MAXARG)
    {
        fprintf(2, "xargs: too many arguments.\n");
        exit(1);
    }
    char buf[MAXSZ];
    char *x_argv[MAXARG];

    // 复制原始参数 (跳过 "xargs")
    for (int i = 1; i < argc; ++i)
    {
        x_argv[i - 1] = argv[i];
    }
    int base_argc = argc - 1;

    while (1)
    {
        int n = readline(buf, MAXSZ);
        if (n == 0)
            break; // EOF
        if (buf[0] == '\0')
            continue; // 跳过空行

        // 添加整行作为单个参数
        if (base_argc >= MAXARG - 1)
        {
            fprintf(2, "xargs: too many arguments.\n");
            exit(1);
        }
        x_argv[base_argc] = buf;
        x_argv[base_argc + 1] = 0; // 终止参数数组

        if (fork() == 0)
        {
            exec(x_argv[0], x_argv);
            fprintf(2, "xargs: exec %s failed\n", x_argv[0]);
            exit(1);
        }
        wait(0);
        clearArgv(x_argv, base_argc);
    }
    exit(0);
}


// // 带参数列表，执行某个程序
// void run(char *program, char **args) {
// 	if(fork() == 0) { // child exec
// 		exec(program, args);
// 		exit(0);
// 	}
// 	return; // parent return
// }
// // echo 1\n2 | xargs echo hello
// int main(int argc, char *argv[]){
// 	char buf[2048]; // 读入时使用的内存池
// 	char *p = buf, *last_p = buf; // 当前参数的结束、开始指针
// 	char *argsbuf[128]; // 全部参数列表，字符串指针数组，包含 argv 传进来的参数和 stdin 读入的参数
// 	char **args = argsbuf; // 指向 argsbuf 中第一个从 stdin 读入的参数
// 	for(int i=1;i<argc;i++) {
// 		// 将 argv 提供的参数加入到最终的参数列表中
// 		*args = argv[i];
// 		args++;
// 	}
// 	char **pa = args; // 开始读入参数
// 	int oldp = 0;
// 	*p = 0;
// 	p++;
// 	last_p++;
// 	while(read(0, p, 1) != 0) {
// 		if(*p == ' ' || (*(p-1) == '\\' && *p == 'n') || *p == '\n') {
// 			oldp = 1;
// 			// 读入一个参数完成（以空格分隔，如 `echo hello world`，则 hello 和 world 各为一个参数）
// 			if(*p != '\n' && *p != ' ')
// 				*(p-1) = '\0';	// 将空格替换为 \0 分割开各个参数，这样可以直接使用内存池中的字符串作为参数字符串
// 			else
// 				*p = '\0';
// 						// 而不用额外开辟空间
// 			*(pa++) = last_p;
// 			last_p = p+1;
			
// 			if(oldp == 1) {
// 				// 读入一行完成
// 				*pa = 0; // 参数列表末尾用 null 标识列表结束
// 				run(argv[1], argsbuf); // 执行最后一行指令
// 				pa = args; // 重置读入参数指针，准备读入下一行
// 				oldp = 0;
// 			}
// 		}
// 		p++;
// 	}
// 	if(pa != args) { // 如果最后一行不是空行
// 		// 收尾最后一个参数
// 		*p = '\0';
// 		*(pa++) = last_p;
// 		// 收尾最后一行
// 		*pa = 0; // 参数列表末尾用 null 标识列表结束
// 		// 执行最后一行指令
// 		run(argv[1], argsbuf);
// 	}
// 	while(wait(0) != -1) {}; // 循环等待所有子进程完成，每一次 wait(0) 等待一个
// 	exit(0);
// }