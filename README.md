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
segment_display.v : HJ  



-tb
--top
---card_gen

-tb_fpga
--segment_display
---top_display
