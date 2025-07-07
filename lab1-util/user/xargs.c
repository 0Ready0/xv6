#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/param.h"
#include "kernel/fs.h"
#include "user/user.h"

#define MSGSIZE 16

// echo hello | xargs echo bye
// echo hello默认情况下为标准输出，但是由于管道存在，将输出进行重定向
// | 将左侧的标准输出重定向为标准输入
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



// 带参数列表，执行某个程序
void run(char *program, char **args) {
	if(fork() == 0) { // child exec
		exec(program, args);
		exit(0);
	}
	return; // parent return
}

int main(int argc, char *argv[]){
	// 手动绘图，更加详细流程
	// 1. for循环  将argv中参数读出 -----保存至----->  argsbuf
	// 2. while函数  然后将echo的读入参数读出  ----保存至---->  argsbuf的尾部
	// 3. 遇到'\n'结束符，通过exec执行argsbuf中的内容
	// 4. if函数  如果没有'\n'结束符，进行最后的if操作，然后   再  通过exec执行argsbuf中的内容

	char buf[2048]; // 读入时使用的内存池
	char *p = buf, *last_p = buf; // 当前参数的结束、开始指针
	char *argsbuf[128]; // 全部参数列表，字符串指针数组，包含 argv 传进来的参数和 stdin 读入的参数
	char **args = argsbuf; // 指向 argsbuf 中第一个从 stdin 读入的参数
	for(int i=1;i<argc;i++) {
		// 将 argv 提供的参数加入到最终的参数列表中
		*args = argv[i];
		args++;
	}
	char **pa = args; // 开始读入参数
	while(read(0, p, 1) != 0) {
		if(*p == ' ' || *p == '\n') {
			// 读入一个参数完成（以空格分隔，如 `echo hello world`，则 hello 和 world 各为一个参数）
			*p = '\0';	// 将空格替换为 \0 分割开各个参数，这样可以直接使用内存池中的字符串作为参数字符串
						// 而不用额外开辟空间
			*(pa++) = last_p;
			last_p = p+1;

			if(*p == '\n') {
				// 读入一行完成
				*pa = 0; // 参数列表末尾用 null 标识列表结束
				run(argv[1], argsbuf); // 执行最后一行指令
				pa = args; // 重置读入参数指针，准备读入下一行
			}
		}
		p++;
	}
    // 举例 echo hello world | xargs echo bye
    // 那么上述循环使argsbuf中的元素为: 
    // argsbuf[0]:"echo"
    // argsbuf[1]:"bye"
    // argsbuf[2]:"hello"
    // argsbuf[0]:"world"
    // argsbuf[0]:"null"
	
    if(pa != args) { // 如果最后一行不是空行（处理标准输入（stdin）不以换行符结尾的情况）
		// 收尾最后一个参数
		*p = '\0';
		*(pa++) = last_p;
		// 收尾最后一行
		*pa = 0; // 参数列表末尾用 null 标识列表结束
		// 执行最后一行指令
		run(argv[1], argsbuf);
	}
	while(wait(0) != -1) {}; // 循环等待所有子进程完成，每一次 wait(0) 等待一个
	exit(0);
}