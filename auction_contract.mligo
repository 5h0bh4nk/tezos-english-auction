parameter (or
            (or %adminAndInteract
              (or
                (or
                  (or %admin (or (unit %confirm_admin) (bool %pause))
                             (address %set_admin))
                  (nat %bid))
                (or (nat %cancel) (nat %resolve)))
              (never %update_allowed))
            (pair %configure (mutez %opening_price)
                             (pair (nat %min_raise_percent)
                                   (pair (mutez %min_raise)
                                         (pair (nat %round_time)
                                               (pair (nat %extend_time)
                                                     (pair
                                                       (list %asset (pair
                                                                     (address %fa2_address)
                                                                     (list %fa2_batch (pair
                                                                                       (nat %token_id)
                                                                                       (nat %amount)))))
                                                       (pair (timestamp %start_time)
                                                             (timestamp %end_time)))))))));
storage (pair
          (option %admin (pair (pair (address %admin) (bool %paused))
                              (option %pending_admin address)))
          (pair (nat %current_id)
                (pair (nat %max_auction_time)
                      (pair (nat %max_config_to_start_time)
                            (pair
                              (big_map %auctions nat
                                                 (pair (address %seller)
                                                       (pair (mutez %current_bid)
                                                             (pair
                                                               (timestamp %start_time)
                                                               (pair
                                                                 (timestamp %last_bid_time)
                                                                 (pair (int %round_time)
                                                                       (pair
                                                                         (int %extend_time)
                                                                         (pair
                                                                           (list %asset (pair
                                                                                         (address %fa2_address)
                                                                                         (list %fa2_batch (pair
                                                                                                           (nat %token_id)
                                                                                                           (nat %amount)))))
                                                                           (pair
                                                                             (nat %min_raise_percent)
                                                                             (pair
                                                                               (mutez %min_raise)
                                                                               (pair
                                                                                 (timestamp %end_time)
                                                                                 (address %highest_bidder))))))))))))
                              (pair (unit %allowlist)
                                    (pair %fee (address %fee_address) (nat %fee_percent))))))));
code { LAMBDA
         (option (pair (pair address bool) (option address)))
         unit
         { IF_NONE
             {}
             { CAR ; CAR ; SENDER ; COMPARE ; NEQ ; IF { PUSH string "NOT_AN_ADMIN" ; FAILWITH } {} } ;
           UNIT } ;
       LAMBDA
         (option (pair (pair address bool) (option address)))
         unit
         { IF_NONE {} { CAR ; CDR ; IF { PUSH string "PAUSED" ; FAILWITH } {} } ; UNIT } ;
       LAMBDA (pair bool string) unit { UNPAIR ; IF { DROP } { FAILWITH } ; UNIT } ;
       DUP ;
       LAMBDA
         (pair (lambda (pair bool string) unit) string)
         unit
         { UNPAIR ;
           SWAP ;
           PUSH string "DONT_TRANSFER_TEZ_TO_" ;
           CONCAT ;
           PUSH mutez 0 ;
           AMOUNT ;
           COMPARE ;
           EQ ;
           PAIR ;
           EXEC } ;
       SWAP ;
       APPLY ;
       LAMBDA
         (pair mutez address)
         operation
         { UNPAIR ;
           SWAP ;
           CONTRACT unit ;
           IF_NONE { PUSH string "ADDRESS_DOES_NOT_RESOLVE" ; FAILWITH } {} ;
           SWAP ;
           UNIT ;
           TRANSFER_TOKENS } ;
       LAMBDA
         (pair (pair (list (pair address (list (pair nat nat)))) address) address)
         (list operation)
         { UNPAIR ;
           UNPAIR ;
           MAP { DUP ;
                 CDR ;
                 MAP { DUP 4 ; PAIR } ;
                 SWAP ;
                 CAR ;
                 CONTRACT %transfer (list (pair (address %from_)
                                               (list %txs (pair (address %to_)
                                                               (pair (nat %token_id)
                                                                     (nat %amount)))))) ;
                 IF_NONE { PUSH string "ADDRESS_DOES_NOT_RESOLVE" ; FAILWITH } {} ;
                 PUSH mutez 0 ;
                 NIL (pair address (list (pair address (pair nat nat)))) ;
                 DIG 3 ;
                 DUP 5 ;
                 PAIR ;
                 CONS ;
                 TRANSFER_TOKENS } ;
           SWAP ;
           DROP ;
           SWAP ;
           DROP } ;
       LAMBDA
         (pair nat
               (pair (option (pair (pair address bool) (option address)))
                     (pair nat
                           (pair nat
                                 (pair nat
                                       (pair
                                         (big_map nat
                                                  (pair address
                                                        (pair mutez
                                                              (pair timestamp
                                                                    (pair timestamp
                                                                          (pair int
                                                                                (pair
                                                                                  int
                                                                                  (pair
                                                                                    (list (pair
                                                                                           address
                                                                                           (list (pair
                                                                                                  nat
                                                                                                  nat))))
                                                                                    (pair
                                                                                      nat
                                                                                      (pair
                                                                                        mutez
                                                                                        (pair
                                                                                          timestamp
                                                                                          address)))))))))))
                                         (pair unit (pair address nat))))))))
         (pair address
               (pair mutez
                     (pair timestamp
                           (pair timestamp
                                 (pair int
                                       (pair int
                                             (pair
                                               (list (pair address (list (pair nat nat))))
                                               (pair nat
                                                     (pair mutez
                                                           (pair timestamp address))))))))))
         { UNPAIR ;
           SWAP ;
           GET 9 ;
           SWAP ;
           GET ;
           IF_NONE { PUSH string "AUCTION_DOES_NOT_EXIST" ; FAILWITH } {} } ;
       LAMBDA
         (pair address
               (pair mutez
                     (pair timestamp
                           (pair timestamp
                                 (pair int
                                       (pair int
                                             (pair
                                               (list (pair address (list (pair nat nat))))
                                               (pair nat
                                                     (pair mutez
                                                           (pair timestamp address))))))))))
         bool
         { DUP ; GET 9 ; SWAP ; DUP ; DUG 2 ; GET 7 ; ADD ; NOW ; COMPARE ; GT ; SWAP ; GET 19 ; NOW ; COMPARE ; GE ; OR } ;
       LAMBDA
         (pair address
               (pair mutez
                     (pair timestamp
                           (pair timestamp
                                 (pair int
                                       (pair int
                                             (pair
                                               (list (pair address (list (pair nat nat))))
                                               (pair nat
                                                     (pair mutez
                                                           (pair timestamp address))))))))))
         bool
         { DUP ; CAR ; SWAP ; GET 20 ; COMPARE ; EQ } ;
       DUP ;
       LAMBDA
         (pair
           (lambda
             (pair address
                   (pair mutez
                         (pair timestamp
                               (pair timestamp
                                     (pair int
                                           (pair int
                                                 (pair
                                                   (list (pair address
                                                              (list (pair nat nat))))
                                                   (pair nat
                                                         (pair mutez
                                                               (pair timestamp address))))))))))
             bool)
           (pair address
                 (pair mutez
                       (pair timestamp
                             (pair timestamp
                                   (pair int
                                         (pair int
                                               (pair
                                                 (list (pair address
                                                            (list (pair nat nat))))
                                                 (pair nat
                                                       (pair mutez
                                                             (pair timestamp address)))))))))))
         bool
         { UNPAIR ; SWAP ; EXEC } ;
       SWAP ;
       APPLY ;
       DIG 10 ;
       UNPAIR ;
       IF_LEFT
         { IF_LEFT
             { IF_LEFT
                 { DIG 6 ;
                   DROP ;
                   DIG 7 ;
                   DROP ;
                   IF_LEFT
                     { DIG 2 ;
                       DROP ;
                       DIG 2 ;
                       DROP ;
                       DIG 2 ;
                       DROP ;
                       DIG 2 ;
                       DROP ;
                       DIG 2 ;
                       DROP ;
                       DIG 2 ;
                       DROP ;
                       DIG 2 ;
                       DROP ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       CAR ;
                       SWAP ;
                       IF_LEFT
                         { IF_LEFT
                             { DROP ;
                               DIG 2 ;
                               DROP ;
                               IF_NONE
                                 { PUSH string "NO_ADMIN_CAPABILITIES_CONFIGURED" ;
                                   FAILWITH }
                                 { DUP ;
                                   CDR ;
                                   IF_NONE
                                     { PUSH string "NO_PENDING_ADMIN" ; FAILWITH }
                                     { SENDER ;
                                       COMPARE ;
                                       EQ ;
                                       IF
                                         { CAR ; CDR ; NONE address ; SWAP ; SENDER ; PAIR ; PAIR ; SOME }
                                         { PUSH string "NOT_A_PENDING_ADMIN" ; FAILWITH } } } ;
                               NIL operation ;
                               PAIR }
                             { SWAP ;
                               DUP ;
                               DUG 2 ;
                               DIG 4 ;
                               SWAP ;
                               EXEC ;
                               DROP ;
                               SWAP ;
                               IF_NONE
                                 { PUSH string "NO_ADMIN_CAPABILITIES_CONFIGURED" ;
                                   FAILWITH }
                                 { DUP ; CDR ; DUG 2 ; CAR ; CAR ; PAIR ; PAIR ; SOME } ;
                               NIL operation ;
                               PAIR } }
                         { SWAP ;
                           DUP ;
                           DUG 2 ;
                           DIG 4 ;
                           SWAP ;
                           EXEC ;
                           DROP ;
                           SWAP ;
                           IF_NONE
                             { PUSH string "NO_ADMIN_CAPABILITIES_CONFIGURED" ; FAILWITH }
                             { SWAP ; SOME ; SWAP ; CAR ; PAIR ; SOME } ;
                           NIL operation ;
                           PAIR } ;
                       UNPAIR ;
                       DIG 2 ;
                       CDR ;
                       DIG 2 ;
                       PAIR ;
                       SWAP ;
                       PAIR }
                     { DIG 9 ;
                       DROP ;
                       AMOUNT ;
                       SENDER ;
                       DUP 4 ;
                       DUP 4 ;
                       PAIR ;
                       DIG 8 ;
                       SWAP ;
                       EXEC ;
                       DIG 4 ;
                       DIG 2 ;
                       DIG 3 ;
                       PAIR ;
                       DIG 2 ;
                       DIG 3 ;
                       DIG 2 ;
                       UNPAIR ;
                       PUSH string "CALLER_NOT_IMPLICIT" ;
                       SOURCE ;
                       SENDER ;
                       COMPARE ;
                       EQ ;
                       PAIR ;
                       DUP 11 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       DUP 5 ;
                       CAR ;
                       DIG 11 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       PUSH string "NOT_IN_PROGRESS" ;
                       DUP 5 ;
                       DIG 9 ;
                       SWAP ;
                       EXEC ;
                       NOT ;
                       DUP 6 ;
                       GET 5 ;
                       NOW ;
                       COMPARE ;
                       GE ;
                       AND ;
                       PAIR ;
                       DUP 10 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       PUSH string "SEllER_CANT_BID" ;
                       DUP 5 ;
                       CAR ;
                       DUP 4 ;
                       COMPARE ;
                       NEQ ;
                       PAIR ;
                       DUP 10 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       PUSH string "NO_SELF_OUTBIDS" ;
                       DUP 5 ;
                       GET 20 ;
                       DUP 4 ;
                       COMPARE ;
                       NEQ ;
                       PAIR ;
                       DIG 9 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       DUP ;
                       DUP 5 ;
                       DUP ;
                       DIG 9 ;
                       SWAP ;
                       EXEC ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 3 ;
                       DUP 4 ;
                       COMPARE ;
                       GE ;
                       AND ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 17 ;
                       DUP 3 ;
                       GET 3 ;
                       ADD ;
                       DUP 4 ;
                       COMPARE ;
                       GE ;
                       DUP 3 ;
                       GET 3 ;
                       DUP 4 ;
                       GET 15 ;
                       PUSH nat 100 ;
                       SWAP ;
                       DIG 2 ;
                       MUL ;
                       EDIV ;
                       IF_NONE
                         { PUSH string "DIVISION_BY_ZERO" ; FAILWITH }
                         { UNPAIR ;
                           PUSH mutez 0 ;
                           DIG 2 ;
                           COMPARE ;
                           GT ;
                           IF { PUSH mutez 1 ; ADD } {} } ;
                       DIG 3 ;
                       GET 3 ;
                       ADD ;
                       DIG 3 ;
                       COMPARE ;
                       GE ;
                       OR ;
                       OR ;
                       IF
                         {}
                         { NOW ;
                           DUP 5 ;
                           GET 7 ;
                           DUP 6 ;
                           GET 20 ;
                           PAIR ;
                           AMOUNT ;
                           DUP 7 ;
                           GET 3 ;
                           PAIR ;
                           PAIR ;
                           PAIR ;
                           PUSH string "INVALID_BID_AMOUNT" ;
                           PAIR ;
                           FAILWITH } ;
                       DUP 4 ;
                       DIG 6 ;
                       SWAP ;
                       EXEC ;
                       IF
                         { DIG 5 ; DROP ; NIL operation }
                         { DUP 4 ;
                           GET 20 ;
                           DUP 5 ;
                           GET 3 ;
                           PAIR ;
                           DIG 6 ;
                           SWAP ;
                           EXEC ;
                           NIL operation ;
                           SWAP ;
                           CONS } ;
                       DUP 5 ;
                       GET 11 ;
                       NOW ;
                       DUP 7 ;
                       GET 19 ;
                       SUB ;
                       COMPARE ;
                       LE ;
                       IF { DUP 5 ; GET 11 ; NOW ; ADD } { DUP 5 ; GET 19 } ;
                       DUP 6 ;
                       GET 4 ;
                       DIG 3 ;
                       PAIR ;
                       DIG 5 ;
                       CAR ;
                       PAIR ;
                       DIG 3 ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 19 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 17 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 15 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 13 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 11 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 9 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 7 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 5 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 3 ;
                       PAIR ;
                       SWAP ;
                       CAR ;
                       PAIR ;
                       DUP ;
                       GET 8 ;
                       NOW ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 5 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 3 ;
                       PAIR ;
                       SWAP ;
                       CAR ;
                       PAIR ;
                       DUP ;
                       GET 20 ;
                       DIG 2 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 17 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 15 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 13 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 11 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 9 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 7 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 5 ;
                       PAIR ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       GET 3 ;
                       PAIR ;
                       SWAP ;
                       CAR ;
                       PAIR ;
                       DUP 4 ;
                       GET 10 ;
                       DUP 5 ;
                       GET 9 ;
                       DIG 2 ;
                       SOME ;
                       DIG 4 ;
                       UPDATE ;
                       PAIR ;
                       DUP 3 ;
                       GET 7 ;
                       PAIR ;
                       DUP 3 ;
                       GET 5 ;
                       PAIR ;
                       DUP 3 ;
                       GET 3 ;
                       PAIR ;
                       DIG 2 ;
                       CAR ;
                       PAIR ;
                       SWAP ;
                       PAIR } }
                 { DIG 3 ;
                   DROP ;
                   DIG 10 ;
                   DROP ;
                   IF_LEFT
                     { SWAP ;
                       DUP ;
                       DUG 2 ;
                       CAR ;
                       DIG 10 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       PAIR ;
                       DIG 5 ;
                       SWAP ;
                       EXEC ;
                       DUP ;
                       CAR ;
                       SENDER ;
                       COMPARE ;
                       EQ ;
                       IF
                         {}
                         { PUSH string "OR_A_SELLER" ;
                           DUP 4 ;
                           CAR ;
                           IF_NONE
                             { DROP }
                             { CAR ;
                               CAR ;
                               SENDER ;
                               COMPARE ;
                               NEQ ;
                               IF
                                 { PUSH string "_" ;
                                   CONCAT ;
                                   PUSH string "NOT_AN_ADMIN" ;
                                   CONCAT ;
                                   FAILWITH }
                                 { DROP } } } ;
                       DUP ;
                       PUSH string "AUCTION_ENDED" ;
                       SWAP ;
                       DIG 6 ;
                       SWAP ;
                       EXEC ;
                       NOT ;
                       PAIR ;
                       DIG 8 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       PUSH string "CANCEL" ;
                       DIG 7 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       DUP ;
                       CAR ;
                       SELF_ADDRESS ;
                       DUP 3 ;
                       GET 13 ;
                       PAIR ;
                       PAIR ;
                       DIG 5 ;
                       SWAP ;
                       EXEC ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       DIG 5 ;
                       SWAP ;
                       EXEC ;
                       IF
                         { SWAP ; DROP ; DIG 3 ; DROP }
                         { SWAP ; DUP ; GET 20 ; SWAP ; GET 3 ; PAIR ; DIG 4 ; SWAP ; EXEC ; CONS } ;
                       DUP 3 ;
                       GET 10 ;
                       DUP 4 ;
                       GET 9 ;
                       DIG 3 ;
                       NONE (pair address
                                  (pair mutez
                                        (pair timestamp
                                              (pair timestamp
                                                    (pair int
                                                          (pair int
                                                                (pair
                                                                  (list (pair address
                                                                             (list (pair
                                                                                    nat
                                                                                    nat))))
                                                                  (pair nat
                                                                        (pair mutez
                                                                              (pair
                                                                                timestamp
                                                                                address)))))))))) ;
                       SWAP ;
                       UPDATE ;
                       PAIR ;
                       DUP 3 ;
                       GET 7 ;
                       PAIR ;
                       DUP 3 ;
                       GET 5 ;
                       PAIR ;
                       DUP 3 ;
                       GET 3 ;
                       PAIR ;
                       DIG 2 ;
                       CAR ;
                       PAIR ;
                       SWAP ;
                       PAIR }
                     { SWAP ;
                       DUP ;
                       DUG 2 ;
                       CAR ;
                       DIG 10 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       PAIR ;
                       DIG 5 ;
                       SWAP ;
                       EXEC ;
                       DUP ;
                       PUSH string "AUCTION_NOT_ENDED" ;
                       SWAP ;
                       DIG 6 ;
                       SWAP ;
                       EXEC ;
                       PAIR ;
                       DIG 8 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       PUSH string "RESOLVE" ;
                       DIG 7 ;
                       SWAP ;
                       EXEC ;
                       DROP ;
                       DUP ;
                       GET 20 ;
                       SELF_ADDRESS ;
                       DUP 3 ;
                       GET 13 ;
                       PAIR ;
                       PAIR ;
                       DIG 5 ;
                       SWAP ;
                       EXEC ;
                       SWAP ;
                       DUP ;
                       DUG 2 ;
                       DIG 5 ;
                       SWAP ;
                       EXEC ;
                       IF
                         { SWAP ; DROP ; DIG 3 ; DROP }
                         { SWAP ;
                           DUP ;
                           DUG 2 ;
                           GET 3 ;
                           DUP 5 ;
                           GET 14 ;
                           PUSH nat 100 ;
                           SWAP ;
                           DIG 2 ;
                           MUL ;
                           EDIV ;
                           IF_NONE { PUSH string "DIV by 0" ; FAILWITH } {} ;
                           CAR ;
                           DUP ;
                           PUSH mutez 0 ;
                           COMPARE ;
                           NEQ ;
                           IF
                             { DUP 5 ; GET 13 ; SWAP ; DUP ; DUG 2 ; PAIR ; DUP 7 ; SWAP ; EXEC ; DIG 2 ; SWAP ; CONS }
                             { SWAP } ;
                           SWAP ;
                           DUP 3 ;
                           GET 3 ;
                           SUB ;
                           DUP ;
                           PUSH mutez 0 ;
                           COMPARE ;
                           NEQ ;
                           IF
                             { DIG 2 ; CAR ; SWAP ; PAIR ; DIG 4 ; SWAP ; EXEC ; CONS }
                             { DROP ; SWAP ; DROP ; DIG 3 ; DROP } } ;
                       DUP 3 ;
                       GET 10 ;
                       DUP 4 ;
                       GET 9 ;
                       DIG 3 ;
                       NONE (pair address
                                  (pair mutez
                                        (pair timestamp
                                              (pair timestamp
                                                    (pair int
                                                          (pair int
                                                                (pair
                                                                  (list (pair address
                                                                             (list (pair
                                                                                    nat
                                                                                    nat))))
                                                                  (pair nat
                                                                        (pair mutez
                                                                              (pair
                                                                                timestamp
                                                                                address)))))))))) ;
                       SWAP ;
                       UPDATE ;
                       PAIR ;
                       DUP 3 ;
                       GET 7 ;
                       PAIR ;
                       DUP 3 ;
                       GET 5 ;
                       PAIR ;
                       DUP 3 ;
                       GET 3 ;
                       PAIR ;
                       DIG 2 ;
                       CAR ;
                       PAIR ;
                       SWAP ;
                       PAIR } } }
             { SWAP ;
               DROP ;
               SWAP ;
               DROP ;
               SWAP ;
               DROP ;
               SWAP ;
               DROP ;
               SWAP ;
               DROP ;
               SWAP ;
               DROP ;
               SWAP ;
               DROP ;
               SWAP ;
               DROP ;
               SWAP ;
               DROP ;
               SWAP ;
               DROP ;
               SWAP ;
               DROP ;
               NEVER } }
         { DIG 2 ;
           DROP ;
           DIG 2 ;
           DROP ;
           DIG 2 ;
           DROP ;
           DIG 2 ;
           DROP ;
           DIG 3 ;
           DROP ;
           PUSH string "INVALID_FEE" ;
           PUSH nat 100 ;
           DUP 4 ;
           GET 14 ;
           COMPARE ;
           LE ;
           PAIR ;
           DUP 6 ;
           SWAP ;
           EXEC ;
           DROP ;
           SWAP ;
           SENDER ;
           DUP 3 ;
           DUP 3 ;
           CAR ;
           DIG 9 ;
           SWAP ;
           EXEC ;
           DROP ;
           DUP 3 ;
           CAR ;
           DIG 8 ;
           SWAP ;
           EXEC ;
           DROP ;
           DUP 3 ;
           GET 11 ;
           SWAP ;
           DUP ;
           DUG 2 ;
           GET 11 ;
           ITER { DROP } ;
           DROP ;
           DUP ;
           GET 13 ;
           PUSH string "INVALID_END_TIME" ;
           SWAP ;
           DUP 3 ;
           GET 14 ;
           COMPARE ;
           GT ;
           PAIR ;
           DUP 8 ;
           SWAP ;
           EXEC ;
           DROP ;
           PUSH string "INVALID_AUCTION_TIME" ;
           DUP 4 ;
           GET 5 ;
           DUP 3 ;
           GET 13 ;
           DUP 4 ;
           GET 14 ;
           SUB ;
           ABS ;
           COMPARE ;
           LE ;
           PAIR ;
           DUP 8 ;
           SWAP ;
           EXEC ;
           DROP ;
           PUSH string "INVALID_START_TIME" ;
           NOW ;
           DUP 3 ;
           GET 13 ;
           COMPARE ;
           GE ;
           PAIR ;
           DUP 8 ;
           SWAP ;
           EXEC ;
           DROP ;
           PUSH string "MAX_CONFIG_TO_START_TIME_VIOLATED" ;
           DUP 4 ;
           GET 7 ;
           NOW ;
           DUP 4 ;
           GET 13 ;
           SUB ;
           ABS ;
           COMPARE ;
           LE ;
           PAIR ;
           DUP 8 ;
           SWAP ;
           EXEC ;
           DROP ;
           PUSH string "INVALID_OPENING_PRICE" ;
           PUSH mutez 0 ;
           DUP 3 ;
           CAR ;
           COMPARE ;
           GT ;
           PAIR ;
           DUP 8 ;
           SWAP ;
           EXEC ;
           DROP ;
           PUSH string "CONFIGURE" ;
           DIG 6 ;
           SWAP ;
           EXEC ;
           DROP ;
           PUSH string "INVALID_ROUND_TIME" ;
           PUSH nat 0 ;
           DUP 3 ;
           GET 7 ;
           COMPARE ;
           GT ;
           PAIR ;
           DUP 7 ;
           SWAP ;
           EXEC ;
           DROP ;
           PUSH string "INVALID_RAISE_CONFIGURATION" ;
           PUSH mutez 0 ;
           DUP 3 ;
           GET 5 ;
           COMPARE ;
           GT ;
           PUSH nat 0 ;
           DUP 4 ;
           GET 3 ;
           COMPARE ;
           GT ;
           AND ;
           PAIR ;
           DIG 6 ;
           SWAP ;
           EXEC ;
           DROP ;
           DUP 3 ;
           GET 10 ;
           DUP 4 ;
           GET 9 ;
           DUP 4 ;
           DUP 4 ;
           GET 14 ;
           PAIR ;
           DUP 4 ;
           GET 5 ;
           PAIR ;
           DUP 4 ;
           GET 3 ;
           PAIR ;
           DUP 4 ;
           GET 11 ;
           PAIR ;
           DUP 4 ;
           GET 9 ;
           INT ;
           PAIR ;
           DUP 4 ;
           GET 7 ;
           INT ;
           PAIR ;
           DUP 4 ;
           GET 13 ;
           PAIR ;
           DUP 4 ;
           GET 13 ;
           PAIR ;
           DIG 3 ;
           CAR ;
           PAIR ;
           DIG 3 ;
           PAIR ;
           SOME ;
           DUP 4 ;
           GET 3 ;
           UPDATE ;
           PAIR ;
           SWAP ;
           DUP ;
           DUG 2 ;
           GET 7 ;
           PAIR ;
           SWAP ;
           DUP ;
           DUG 2 ;
           GET 5 ;
           PAIR ;
           SWAP ;
           DUP ;
           DUG 2 ;
           GET 3 ;
           PAIR ;
           SWAP ;
           DUP ;
           DUG 2 ;
           CAR ;
           PAIR ;
           DUP ;
           GET 4 ;
           PUSH nat 1 ;
           DIG 3 ;
           GET 3 ;
           ADD ;
           PAIR ;
           SWAP ;
           CAR ;
           PAIR ;
           SELF_ADDRESS ;
           SENDER ;
           DIG 3 ;
           GET 11 ;
           PAIR ;
           PAIR ;
           DIG 2 ;
           SWAP ;
           EXEC ;
           PAIR } }
