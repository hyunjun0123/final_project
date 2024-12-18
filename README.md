변수 명 정리

player_current_score -> display12 : 앞에서 두 칸  
player_new_card -> display34 : 뒤에서 두 칸    
player_current_score_split  
player_new_card_split  
dealer_current_score  
current_coin  

double_check : is 0 -> double  
can_split : is 1 -> split

Phase  
Phase 0 : Betting Phase, Dealer Card Draw  
Phase 1 : Player Card Draw  
Phase 2 : Hit, Stand  
Phase 4 : Split  
Phase 6 : Split first card  
Phase 8 : Split second card  
Phase 11 : Dealer Second Turn  
Phase 15 : Result Phase  

Plan  
Wave form Check : DW  
Phase2 : Ace display -> 61 : DW  
-> current display 1

segment_display.v : HJ  

이후 예외처리 : ex) dealer BlackJack  


A : decimal 61 (?)  
b : decimal 62  
d : decimal 63  



12/18  
Implementation Problems & Questions    
1) current_coin is 5-bit. Max coin is 31.
2) dealer의 2nd phase에서, total sum이 17보다 작을 때 딜러가 카드를 뽑는 상황의 display는 어떻게 되는가?
-> 현재는 clock이 들어올 때마다 뽑아서, 최종으로 17이 넘는 순간에 display되게 되어 있음. (문제 없으면 그냥 가도 됨)  
3) (1, 1)을 뽑았을 경우 display 방법 (A,1) or (1,A) 일단 (A,1)로 구현 함.  
