-module(main).

-export([main/0, find_v/1, find_h/1, find_dr/1, find_dl/1, find_cross/1]).

rec_all(0, Res) ->
    Res;
rec_all(Counter, Acc) ->
    receive
        {_, Res} ->
            rec_all(Counter - 1, Acc + Res)
    end.

readfile() ->
    case file:read_file("./input.txt") of
        {ok, Bin} ->
            Lines = binary:split(Bin, [<<"\n">>], [global]),
            lists:droplast(Lines);
        {err, Reason} ->
            exit(1, Reason)
    end.

matches([], Acc, _) ->
    Acc;
matches([X | Xs], Acc, Pattern) ->
    Matches = binary:matches(X, [Pattern]),
    A = Acc + length(Matches),
    matches(Xs, A, Pattern).

compute() ->
    receive
        {From, S, Pattern} ->
            R = matches(S, 0, Pattern),
            From ! {self(), R}
    end.

find_n(M) ->
    P1 = spawn(fun() -> compute() end),
    P1 ! {self(), M, <<"XMAS">>},
    P2 = spawn(fun() -> compute() end),
    P2 ! {self(), M, <<"SAMX">>},
    rec_all(2, 0).

transpose([[] | _]) ->
    [];
transpose(M) ->
    [lists:map(fun hd/1, M) | transpose(lists:map(fun tl/1, M))].

pad_ltr([], _, _) ->
    [];
% let M the input, LPad must be length(M)-1, RPad must be 0
pad_ltr([X | Xs], LPad, RPad) ->
    P = lists:duplicate(LPad, "0") ++ X ++ lists:duplicate(RPad, "0"),
    [lists:flatten(P) | pad_ltr(Xs, LPad - 1, RPad + 1)].

pad_rtl([], _, _) ->
    [];
% let M the input, LPad must be 0, RPad must be length(M)-1
pad_rtl([X | Xs], LPad, RPad) ->
    P = lists:duplicate(LPad, "0") ++ X ++ lists:duplicate(RPad, "0"),
    [lists:flatten(P) | pad_rtl(Xs, LPad + 1, RPad - 1)].

find_h(Pid) ->
    Res = find_n(readfile()),
    Pid ! {self(), Res}.

find_v(Pid) ->
    Lines = readfile(),
    T = transpose(lists:map(fun binary:bin_to_list/1, Lines)),
    M = lists:map(fun binary:list_to_bin/1, T),
    Res = find_n(M),
    Pid ! {self(), Res}.

find_dr(Pid) ->
    Lines = readfile(),
    P = pad_ltr(lists:map(fun binary:bin_to_list/1, Lines), length(Lines), 0),
    T = transpose(P),
    M = lists:map(fun binary:list_to_bin/1, T),
    Res = find_n(M),
    Pid ! {self(), Res}.

find_dl(Pid) ->
    Lines = readfile(),
    P = pad_rtl(lists:map(fun binary:bin_to_list/1, Lines), 0, length(Lines)),
    T = transpose(P),
    M = lists:map(fun binary:list_to_bin/1, T),
    Res = find_n(M),
    Pid ! {self(), Res}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a_x([], _) ->
    [];
a_x(X, Pos) ->
    case hd(X) of
        65 ->
            [Pos | a_x(tl(X), Pos + 1)];
        _ ->
            a_x(tl(X), Pos + 1)
    end.

a_pos([], _) ->
    [];
a_pos([L | Lns], Pos) ->
    Ret = [{X, Pos} || X <- a_x(L, 0)],
    lists:flatten([Ret | a_pos(Lns, Pos + 1)]).

range_c(Row, Start, End) ->
    lists:sublist(
        lists:nthtail(Start, Row), End - Start + 1).

submatrix({M, X, Y}) ->
    StartR = max(0, Y - 1),
    StartC = max(0, X - 1),
    EndR = Y + 1,
    EndC = X + 1,
    Diff = EndR - StartR + 1,
    RangeR =
        lists:sublist(
            lists:nthtail(StartR, M), Diff),
    [range_c(R, StartC, EndC) || R <- RangeR].

valid_sub([A, _, C]) ->
    case {length(A), length(C)} of
        {3, 3} ->
            LR = [lists:nth(1, A)] ++ [lists:nth(3, C)],
            RL = [lists:nth(3, A)] ++ [lists:nth(1, C)],
            case {LR, RL} of
                {"MS", "MS"} ->
                    1;
                {"MS", "SM"} ->
                    1;
                {"SM", "MS"} ->
                    1;
                {"SM", "SM"} ->
                    1;
                _ ->
                    0
            end;
        _ ->
            0
    end;
valid_sub(_) ->
    0.

find_cross(Pid) ->
    Lines = readfile(),
    M = lists:map(fun binary:bin_to_list/1, Lines),
    Centers = lists:flatten([{M, X, Y} || {X, Y} <- a_pos(M, 0)]),
    Subs = lists:map(fun submatrix/1, Centers),
    Res = lists:sum(
              lists:map(fun valid_sub/1, Subs)),
    Pid ! {self(), Res}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

main() ->
    spawn(main, find_h, [self()]),
    spawn(main, find_v, [self()]),
    spawn(main, find_dr, [self()]),
    spawn(main, find_dl, [self()]),
    Pid5 = spawn(main, find_cross, [self()]),
    receive
        {Pid5, R} ->
            ok
    end,
    Res = rec_all(4, 0),
    io:format("~B~n~B~n", [Res, R]).
