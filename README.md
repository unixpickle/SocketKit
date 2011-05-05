SocketKit
=========
SocketKit allows the programmer to use an assortment of TCP-based Objective-C classes to connect to TCP servers, and host a TCP server.  The SKSocket and SKSocketServer class are used only as abstractions for other socket classes such as SKTCPSocket and SKTCPSocketServer.  To use OpenSSL with sockets, there is a simple SKSocket subclass called SKTCPSSLSocket that wraps a TCPSocket for SSL encrypted data communication.

Using SocketKit
===============

To use SocketKit with your Objective-C (iOS or Mac OS X) application, you simply need to copy the SK group (with source code) into your project.  Since SocketKit uses OpenSSL, you have to set a few compiler flags through Xcode.  To do this, go into Target Info > Build Settings > Other Linker Flags.  Add the following flags to this list (exactly as follows.)

    -lssl
    -lcrypto

Testing
=======

Step 1: Run SocketKit.  Once run, you will need to press the 1 key, and hit enter.  If Mac OS X asks if you would like SocketKit to be able to accept incoming network connections, click Allow.

Step 2: Run SSLClient in another Xcode client.  If SSLClient and SocketKit both print out a string saying "Message: [anything]" then the two clients managed to communicate.

Using Different OpenSSL Keys and Certificates.
==============================================

To generate a new OpenSSL key and certificate file, run this command in Terminal:

    openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.pem -out mycert.pem

To use the generated certificate, use this code to create a TCP SSL Socket:

    NSString * pemFile = @"/path/to/mycert.pem";
    SKTCPSSLSocket * sslSocket = [[[SKTCPSSLSocket alloc] initWithServerTCPSocket:aSocket publicKey:pemFile privateKey:pemFile] autorelease];

In the SocketKit Xcode project included with this repository, SSLServerTest has code similar to this in SSLServerTest.m.
