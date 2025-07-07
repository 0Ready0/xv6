// primes 素数
// xv6 每个进程能打开的文件描述符总数只有 16 个

/**
 * 由于一个管道会同时打开一个输入文件和一个输出文件，所以一个管道就占用了 2 个文件描述符，并且复制的子进程还会复制父进程的描述符，
 * 于是跑到第六七层后，就会由于最末端的子进程出现 16 个文件描述符都被占满的情况，导致新管道创建失败。
 * 
 * 解决方式
 *     - 1.关闭管道的两个方向中不需要用到的方向的文件描述符（在具体进程中将管道变成只读/只写）
 *     - 2.子进程创建后，关闭父进程与祖父进程之间的文件描述符（因为子进程并不需要用到之前 stage 的管道）
 *  */ 
// 



#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
# define MAXSIZE 35
const int one = 1;
const int zero = 0;
void prime(int pipe_read){
    int prime_value = 0;
    int num[MAXSIZE];

    // 正确的读取整个数组
    if(read(pipe_read, num, sizeof(num)) <= 0){
        close(pipe_read);
        exit(0);
    }

    for(int i = 2; i < MAXSIZE; ++i){
        if(num[i] == one){
            prime_value = i;
            break;
        }
    }
    if (prime_value == 0) {
        close(pipe_read);
        exit(0);
    }
    printf("pid -> %d: find prime %d\n", getpid(), prime_value);

    // 创建新管道用于子进程
    int new_pipe[2];
    pipe(new_pipe);

    num[prime_value] = zero;
    for(int i = prime_value; i < MAXSIZE; ++i){
        if(i % prime_value == 0){
            num[i] = zero;
        }
    }

    int pid = fork();
    if(pid > 0){
        close(new_pipe[0]);  // 父进程关闭读端
        // 标记倍数（从prime_value*2开始）
        for (int i = prime_value * 2; i < MAXSIZE; i += prime_value) {
            num[i] = zero;
        }
        // 写入处理后的数组
        write(new_pipe[1], num, sizeof(num));
        close(new_pipe[1]);
        wait(0);  // 等待子进程
    }
    if(pid == 0){
        close(new_pipe[1]);  // 子进程关闭写端
        prime(new_pipe[0]);  // 递归处理
        close(new_pipe[0]);
        exit(0);
    }
}

int main(int argc, char**argv){
    int num[MAXSIZE];
    for(int i = 0; i < MAXSIZE; ++i){
        num[i] = one;
    }
    num[0] = zero;
    num[1] = zero;

    int p[2];
    pipe(p);
    int pid = fork();
    if(pid > 0){
        close(p[0]);  // 父进程关闭读端
        write(p[1], num, sizeof(num));  // 写入初始数组
        close(p[1]);
        wait(0);  // 等待子进程链结束
    }
    if(pid == 0){
        close(p[1]);  // 子进程关闭写端
        prime(p[0]);   // 开始筛选
        close(p[0]);
        exit(0);
    }
    exit(0);
}