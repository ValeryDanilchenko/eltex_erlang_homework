-module(protocol).
-include("protocol.hrl").
-export([ipv4/1, ipv4_listener/0]).

ipv4(<<Version:4, IHL:4, ToS:8, TotalLength:16, Identification:16, Flags:3, FragOffset:13,
        TimeToLive:8, Protocol:8, Checksum:16, SourceAddress:32, DestinationAddress:32,
        OptionsAndPadding:((IHL-5)*32)/bits, RemainingData/bytes >>)
    when Version =:= 4 ->
        io:format("Received data ~p ~n", [RemainingData]),
        #ipv4{
            version = Version,
            ihl = IHL,
            tos = ToS,
            total_length = TotalLength,
            identification = Identification,
            flags = Flags,
            fragment_offset = FragOffset,
            ttl = TimeToLive,
            protocol = Protocol,
            header_checksum = Checksum,
            source_address = SourceAddress,
            destination_address = DestinationAddress,
            options = OptionsAndPadding,
            data = RemainingData};
ipv4(Data) ->
    io:format("Invalid data ~p ~n", [Data]),
    erlang:error({badmatch, Data}).
    

ipv4_listener()->
    receive
        {ipv4, From, BinData} ->
        From ! protocol:ipv4(BinData); 
        _Msg ->
            io:format("Invalid message received: ~p ~n", [_Msg]),
            erlang:error(badarg)
    end.


