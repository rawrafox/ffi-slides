require_relative "034-java-start-vm"

string = Java.string("Standard-issue Swedish Shark says 'You could probably reduce the typing a bit, but method overloading makes it much harder than in ObjC!'")

System.out.java_call(:println, "(Ljava/lang/String;)V", string)
