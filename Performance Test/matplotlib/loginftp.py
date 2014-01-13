#coding=utf-8
__author__ = 'royxu'
import pexpect
# 即将 ftp 所要登录的远程主机的域名
ipAddress = '192.168.10.241'
# 登录用户名
loginName = 'actiontec'
# 用户名密码
loginPassword = 'actiontec'

# 拼凑 ftp 命令
cmd = 'ftp ' + ipAddress
# 利用 ftp 命令作为 spawn 类构造函数的参数，生成一个 spawn 类的对象
child = pexpect.spawn(cmd)
# 期望具有提示输入用户名的字符出现
index = child.expect(["(?i)name", "(?i)Unknown host", pexpect.EOF, pexpect.TIMEOUT])
# 匹配到了 "(?i)name"，表明接下来要输入用户名
if ( index == 0 ):
    # 发送登录用户名 + 换行符给子程序.
    child.sendline(loginName)
    # 期望 "(?i)password" 具有提示输入密码的字符出现.
    index = child.expect(["(?i)password", pexpect.EOF, pexpect.TIMEOUT])
    # 匹配到了 pexpect.EOF 或 pexpect.TIMEOUT，表示超时或者 EOF，程序打印提示信息并退出.
    if (index != 0):
        print "ftp login failed"
        child.close(force=True)
        # 匹配到了密码提示符，发送密码 + 换行符给子程序.
    child.sendline(loginPassword)
    # 期望登录成功后，提示符 "ftp>" 字符出现.
    index = child.expect(['ftp>', 'Login incorrect', 'Service not available',
                          pexpect.EOF, pexpect.TIMEOUT])
    # 匹配到了 'ftp>'，登录成功.
    if (index == 0):
        print 'Congratulations! ftp login correct!'
        # 发送 'bin'+ 换行符给子程序，表示接下来使用二进制模式来传输文件.
        child.sendline("bin")
        print 'getting a file...'
        # 向子程序发送下载文件 rmall 的命令.
        child.sendline("get rmall")
        # 期望下载成功后，出现 'Transfer complete.*ftp>'，其实下载成功后,
        # 会出现以下类似于以下的提示信息:
        #    200 PORT command successful.
        #    150 Opening data connection for rmall (548 bytes).
        #    226 Transfer complete.
        #    548 bytes received in 0.00019 seconds (2.8e+03 Kbytes/s)
        # 所以直接用正则表达式 '.*' 将 'Transfer complete' 和提示符 'ftp>' 之间的字符全省去.
        index = child.expect(['Transfer complete.*ftp>', pexpect.EOF, pexpect.TIMEOUT])
        # 匹配到了 pexpect.EOF 或 pexpect.TIMEOUT，表示超时或者 EOF，程序打印提示信息并退出.
        if (index != 0):
            print "failed to get the file"
            child.close(force=True)
            # 匹配到了 'Transfer complete.*ftp>'，表明下载文件成功，打印成功信息，并输入 'bye'，结束 ftp session.
        print 'successfully received the file'
        child.sendline("bye")
    # 用户名或密码不对，会先出现 'Login incorrect'，然后仍会出现 'ftp>'，但是 pexpect 是最小匹配，不是贪婪匹配,
    # 所以如果用户名或密码不对，会匹配到 'Login incorrect'，而不是 'ftp>'，然后程序打印提示信息并退出.
    elif (index == 1):
        print "You entered an invalid login name or password. Program quits!"
        child.close(force=True)
    # 匹配到了 'Service not available'，一般表明 421 Service not available, remote server has
    # closed connection，程序打印提示信息并退出.
    # 匹配到了 pexpect.EOF 或 pexpect.TIMEOUT，表示超时或者 EOF，程序打印提示信息并退出.
    else:
        print "ftp login failed! index = " + index
        child.close(force=True)


# 匹配到了 "(?i)Unknown host"，表示 server 地址不对，程序打印提示信息并退出
elif index == 1:
    print "ftp login failed, due to unknown host"
    child.close(force=True)
# 匹配到了 pexpect.EOF 或 pexpect.TIMEOUT，表示超时或者 EOF，程序打印提示信息并退出
else:
    print "ftp login failed, due to TIMEOUT or EOF"
    child.close(force=True)
