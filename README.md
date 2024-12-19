# 이 코드의 문제점
## w/o split
1) clk edge -> next edge 순으로 트리거되기 때문에, 반응이 느리다. 아마 보드 상에서는 문제가 없을 것으로 보이나, tb를 돌렸을 때 시간 텀이 존재한다.

## w/ split
1) Win,Lose와 같이 두 가지 결과가 동시에 적용된 경우, LED에 불이 두 곳에서 들어와야 함. 기존의 port를 조절해야할 것 같음.
2) Win2, Lose2, Draw2 변수를 만들어놓지 않았음.
3) Phase#5에서 dealer 2nd 결과에 따라 win, lose가 결정되는데, split도 똑같은 state로 정의하기에 어려움이 있어서 임시로 Phase#12를 만들었음.
