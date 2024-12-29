 // SPDX-License-Identifier:GPL-3.0 
pragma solidity >=0.7.0 < 0.9.0;

contract baccarat{

    struct Player{   // 참가자의 구조체
        uint predict;// 예측하는 것에 따라 값이 다르게 저장.
                     // 값이 0이면 소유자 승, 1이면 무승부, 2이면 플레이어 승을 예측
        uint money;  // 참가자의 배팅금 저장
    }

    // 참가자가 중복하여 참가(join 함수) 하지 못하도록 한다.
    mapping (uint=> mapping(address => bool)) public playersAdd;

    // 참가자의 주소를 매핑하여 구조체를 저장. 
    mapping (address => Player) private players;

    address private ownerAdd;// 소유자의 주소 저장
    address[]private playerList;// 참가자의 주소를 저장하는 배열
    uint[] private deck;// 덱을 저장하는 배열
    uint public round = 1;// 라운드 횟수를 나타내는 변수
    uint public playerNum = 0;// 참가자의 명수를 나타내는 변수
    bool public status = true;// 게임의 진행 여부를 알려주는 변수
    
    uint[] private playerCard;// 플레이어 카드를 저장하는 배열
    uint private playerStand;// 플레이어가 스탠드를 했을 때의 값을 나타내는 변수
    uint private playerNatural;// 플레이어가 네츄럴을 했을 때의 값을 나타내는 변수
    uint private playerThird;// 플레이어의 세번째 카드를 저장하는 변수

    uint[] private ownerCard;// 소유자(= 딜러)의 카드를 저장하는 배열
    uint private ownerStand;// 소유자가 스탠드를 했을 때의 값을 나타내는 변수
    uint private ownerNatural;// 소유자가 네츄럴을 했을 때의 값을 나타내는 변수
    
    constructor(){//스마트 컨트랙트를 배포한 사람의 주소를 소유자로 지정 
        ownerAdd = msg.sender;//소유자의 주소를 저장
    }

    function join() external{// 참가하는 함수
        require(msg.sender != ownerAdd, "you are owner");// 소유자는 이 함수에 접근 불가능
        require(playersAdd[round][msg.sender] == false, "Must be the first time.");// 중복 참가 불가능
        require(status == true, "game already start.");// 게임이 진행중일 때 참가 불가능
        playersAdd[round][msg.sender] = true;// 라운드가 달라질 때 다시 참가할 수 있음
        ++playerNum;// 참가자 수 1 증가
    }

    function ownerWin() public payable {// 소유자 승에 걸 때의 함수
        require(playersAdd[round][msg.sender], "You must join the game first.");// 참가자만 접근 가능
        require(msg.value >= 1 ether, "must be 1 ether more.");// 1 이더 이상 지불해야 됨
        payable(ownerAdd).transfer(msg.value);// 소유자에게 배팅금 선불
        Player storage player = players[msg.sender];// 해당 참가자의 주소로 Player 구조체 생성
        playerList.push(msg.sender);// 참가자의 주소를 playerList에 저장
        player.predict = 0;// 구조체에 예측값을 2로 저장(소유자 승은 2)
        player.money = msg.value;// 구조체에 배팅금 저장
    }

    function tie() public payable {// 무승부에 걸 때의 함수
        require(playersAdd[round][msg.sender], "You must join the game first.");// 참가자만 접근 가능
        require(msg.value >= 1 ether, "must be 1 ether more.");// 1 이더 이상 지불해야 됨
        payable(ownerAdd).transfer(msg.value);// 소유자에게 배팅금 선불
        Player storage player = players[msg.sender];// 해당 참가자의 주소로 Player 구조체 생성
        playerList.push(msg.sender);// 참가자의 주소를 playerList에 저장
        player.predict = 1;// 구조체에 예측값을 1로 저장(무승부는 1)
        player.money = msg.value;// 구조체에 배팅금 저장
    }

    function playerWin() public payable {// 플레이어 승에 걸 때에 함수
        require(playersAdd[round][msg.sender], "You must join the game first."); // 참가자만 접근 가능
        require(msg.value >= 1 ether, "must be 1 ether more.");// 1 이더 이상 지불해야 됨
        payable(ownerAdd).transfer(msg.value);// 소유자에게 배팅금 선불
        Player storage player = players[msg.sender];// 해당 참가자의 주소로 Player 구조체 생성
        playerList.push(msg.sender);// 참가자의 주소를 playerList에 저장
        player.predict = 2;// 구조체에 예측값을 0으로 저장(플레이어 승은 0)
        player.money = msg.value;// 구조체에 배팅금 저장
    }

    function payMoney() public view returns(uint){
        // 승리한 참가자에게 소유자는 배팅금을 입금해야 하는데 이 스마트 컨트랙트의 balance를 초과할 수 있으므로
        // 모든 참가자가 승리했다고 가정했을 때의 금액을 소유자가 지불해야한다.
        // payMoney 함수는 소유자가 지불해야하는 금액을 알려줌
        uint sumMoney = 0;// 모든 참가자가 승리했다고 가정했을 때의 금액을 저장하는 변수

        for (uint256 i = 0; i<playerList.length; i++){// 모든 참가자에 대하여
            Player storage player = players[playerList[i]];// 참가자의 구조체에 접근
            if(player.predict == 0){// 소유자 승을 예측한 참가자라면
                sumMoney += player.money * 2;// 해당 참가자의 배팅금의 2배를 변수에 더함
            }
            if(player.predict == 1){// 무승부를 예측한 참가자라면
                sumMoney += player.money * 8;// 해당 참가자의 배팅금의 8배를 변수에 더함
            }
            if(player.predict == 2){// 플레이어 승을 예측한 참가자라면
                sumMoney += player.money * 2;// 해당 참가자의 배팅금의 2배를 변수에 더함
            }
        }
        return sumMoney;// 모든 참가자가 승리했을 때의 금액을 반환
    }

    function start() public payable {// 시작할 때의 함수
        require(msg.sender == ownerAdd, "you are not owner");// 소유자만 해당 함수에 접근 가능
        require(msg.value == payMoney(), "pay money");// 소유자는 모든 참가자가 승리했을 때의 금액을 스마트 컨트렉에 지불

        status = false;// 진행 상태를 false로 바꿈
        delete deck;// 덱 초기화
        delete playerCard;// 플레이어 카드 초기화
        delete ownerCard;// 오너 카드 초기화
        playerNatural = 0;// 플레이어에 해당하는 변수들을 초기화
        playerStand = 0;
        playerThird = 0;
        ownerNatural = 0;// 소유자에 해당하는 변수들을 초기화
        ownerStand = 0;

        createDeck();// 덱을 생성한 뒤 셔플하는 함수
        playerCard.push(getCard());// 플레이어 덱에서 한장의 카드를 저장
        playerCard.push(getCard());// 플레이어 덱에서 한장의 카드를 저장(총 2장 지급)
        ownerCard.push(getCard());// 소유자 덱에서 한장의 카드를 저장
        ownerCard.push(getCard());// 소유자 덱에서 한장의 카드를 저장(총 2장 지급)
    }

    function createDeck() private{// 덱을 생성한 뒤 셔플하는 함수
        uint TJQK = 0;// 10,J,Q,K를 0으로 바꾸기 위한 변수

        for (uint i; i<13; i++){// 13개의 카드 종류에 대하여
            for (uint j; j<4; j++){// 4개의 문양에 대하여
                TJQK = i+1;// 변수에 i+1을 저장
                if (TJQK >= 10){// 변수가 10 이상이라면
                    TJQK = 0;// 변수를 0으로 저장
                }
                deck.push(TJQK);// 덱에 변수들을 저장
            }
        }

        uint n = deck.length; // 덱의 길이를 저장하는 변수
        while (n > 1) { // 덱을 섞기 위한 반복문
            n--; // 덱의 길이를 감소시킴

            // 무작위로 카드를 선택하기 위한 시드 값 생성
            uint seed = uint(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1), n))) % (n + 1);
            uint temp = deck[seed]; // 무작위로 선택된 카드를 임시 변수에 저장
            deck[seed] = deck[n]; // 무작위로 선택된 카드 자리에 덱의 마지막 카드를 넣음
            deck[n] = temp; // 덱의 마지막 카드 자리에 무작위로 선택된 카드를 넣음
        }
    }

    function getCard() private returns(uint){// 카드 한 장을 뽑는 함수
        require(deck.length>0, "no card");// 덱의 길이가 1 이상일 때만 함수에 접근 가능
        uint temp = deck[0];// 덱의 첫번째 카드를 임시 변수에 저장
        deck[0] = deck[deck.length - 1];// 덱의 첫번째 카드를 마지막 카드에 저장
        deck.pop();// 덱의 마지막 카드를 삭제(뽑은 카드를 삭제)
        return temp;// 임시 변수를 반환(덱의 첫번째 카드를 반환)
    }

    function getDeck() public view returns(uint[] memory){// 덱을 보여주는 함수
        return deck;// 덱을 반환
    }

    function getplayercard() public view returns(uint[] memory){// 플레이어 카드를 보여주는 함수
        return playerCard;// 플레이어 카드 반환
    }

    function getownerCard() public view returns(uint[] memory){// 소유자 카드를 보여주는 함수
        return ownerCard;// 소유자 카드 반환
    }

    function getplayertotal() public{// 플레이어의 점수를 룰에 따라서 계산해주는 함수
        uint sum = 0;// 플레이어의 모든 카드를 더하는 변수
        uint ownerSum = 0;// 소유자가 네츄럴인지 판단하는 변수

        for (uint i; i<playerCard.length; i++){// 플레이어의 카드에 대하여
            sum += playerCard[i];// 변수에 더함
            }

        for (uint i; i<ownerCard.length; i++){// 소유자 카드에 대하여
            ownerSum += ownerCard[i];// 변수에 더함
        }


        uint total = sum%10;// 변수의 일의 자리를 저장하는 변수(점수)
        uint isOwnerNatural = ownerSum%10;// 소유자의 일의 자리를 저장하는 변수(네츄럴 판단)

        if (playerCard.length == 2 && isOwnerNatural < 8){// 플레이어 카드의 길이가 2이고 소유자가 네츄럴이 아닐 때
            if (total>=0 && total<6){// 점수가 0 이상 6 미만이라면
                playerThird = getCard();// 세번째 카드를 받고(변수에 getCard 함수를 호출시켜 덱에서 카드 한장을 저장)
                playerCard.push(playerThird);// 플레이어 카드에 저장
                return getplayertotal();//다시 해당 함수를 돌려 카드 합 갱신
            }
            else if (total == 6 || total == 7){// 점수가 6 또는 7일 때
                playerStand = total;// 플레이어는 스탠드 상태(즉, 플레이어의 점수는 변수의 값)
            }
            else{// 점수가 8 이상 일 때
                playerNatural = total;// 플레이어는 네츄럴 상태(플레이어의 점수는 해당 변수 값 + 네츄럴)
            }
        }
        playerStand = total;// 플레이어의 점수 저장
                            // 플레이어가 세번째 카드를 받은 이상 네츄럴이 아니므로 스탠드 상태의 유무는 중요치 않음
    }

    function getownertotal() public{// 소유자의 점수를 룰에 따라서 계산해주는 함수
        uint sum = 0;// 소유자의 모든 카드를 더하는 변수

        for (uint i; i<ownerCard.length; i++){// 소유자의 카드에 대하여
                sum += ownerCard[i];// 변수에 더함
            }

        uint total = sum%10;// 변수의 일의 자리를 저장하는 변수(점수)

        if (ownerCard.length == 2 && playerNatural == 0){// 소유자의 카드의 길이가 2이고 플레이어가 네츄럴이 아닐 때
            if (total>=0 && total <=2){// 소유자의 점수가 0 이상 2 이하라면
                ownerCard.push(getCard());// 카드를 한 장 더 뽑고
                return getownertotal();// 다시 해당 함수를 돌려 카드 합 갱신
            }
            if(playerCard.length == 3){// 플레이어가 카드를 한 장 더 받았을 때
                if (total == 3 && playerThird != 8){// 소유자의 점수가 3이고, 플레이어의 세번째 카드가 8이 아니라면
                    ownerCard.push(getCard());// 카드를 한 장 더 뽑고
                    return getownertotal();// 다시 해당 함수를 돌려 카드 합 갱신
                }
                else if (total == 4){// 소유자의 점수가 3일 때
                    if (playerThird >= 2 && playerThird <= 7){// 플레이어의 세번째 카드가 2 이상 7 이하라면
                        ownerCard.push(getCard());// 카드를 한 장 더 뽑고
                        return getownertotal();// 다시 해당 함수를 돌려 카드 합 갱신
                    }
                }
                else if (total == 5){// 소유자의 점수가 5일 때
                    if (playerThird >= 4 && playerThird <= 7){// 플레이어의 세번째 카드가 4 이상 7 이하라면
                        ownerCard.push(getCard());// 카드를 한 장 더 뽑고
                        return getownertotal();// 다시 해당 함수를 돌려 카드 합 갱신
                    }
                }
                else if (total == 6){// 소유자의 점수가 6일 때
                    if (playerThird == 6 || playerThird == 7){// 플레이어의 세번째 카드가 6이거나 7이라면
                        ownerCard.push(getCard());// 카드를 한 장 더 뽑고
                        return getownertotal();// 다시 해당 함수를 돌려 카드 합 갱신
                    }
                }
                else if (total == 7) {// 소유자의 점수가 7일 때
                    ownerStand = total;// 소유자는 스탠드 상태(점수 저장 + 카드를 추가로 안 받음)
                }
                else{// 소유자의 점수가 8 이상일 때
                    ownerNatural = total;// 소유자는 네츄럴 상태(소유자의 점수는 해당 변수 값 + 네츄럴) 
                }
            }
        }
        ownerStand = total;// 소유자의 점수 저장
    }

    function playerstand() public view returns(uint){// 플레이어의 점수를 반환하는 함수
        return playerStand;// 점수 반환
    }

    function playernatural() public view returns(uint){// 플레이어가 네츄럴 일 때의 점수를 반환하는 함수
        return playerNatural;// 네츄럴 일 때의 점수 반환
    }

    function playerthird() public view returns(uint){// 플레이어의 세번째 카드를 반환하는 함수
        return playerThird;// 세번째 카드 반환
    }

    function ownerstand() public view returns(uint){// 소유자의 점수를 반환하는 함수
        return ownerStand;// 점수 반환
    }

    function ownernatural() public view returns(uint){// 소유자가 네츄럴 일 때의 점수를 반환하는 함수
        return ownerNatural;// 네츄럴 일 때의 점수 반환
    }

    function winner() public payable returns(uint){// 승자를 가리는 함수
        require(msg.sender == ownerAdd, "you are not owner");// 소유자만 해당 함수에 접근 가능
        getplayertotal();// 플레이어의 점수를 먼저 계산
        getownertotal();// 소유자의 점수를 계산
        uint cnt = 0;// cnt의 값에 따라서 결과를 알 수 있도록 임의로 생성
        
        if (ownerNatural > 0 || playerNatural > 0){// 둘 중에 하나라도 네츄럴 상태일 때
            if (ownerNatural > playerNatural){// 소유자의 네츄럴 점수가 더 높다면
                for (uint256 i = 0; i<playerList.length; i++){// 모든 참가자에 대하여
                    Player storage player = players[playerList[i]];// 참가자의 주소에 해당하는 구조체를 호출
                    if(player.predict == 0){// 소유자의 승에 배팅한 참가자가 있다면
                        payable(playerList[i]).transfer(player.money * 2);// 배팅금의 2배 입금
                    }
                }
                uint change = address(this).balance;// 현재 컨트랙에 남은 돈
                payable(ownerAdd).transfer(change);// 소유자에게 입금
                status = true;// 게임 끝
                round += 1;// 라운드 증가
                return cnt;// 0 반환(0일 때 소유자 네츄럴 승)
            }
            else if(ownerNatural == playerNatural){// 둘의 네츄럴 점수가 같다면
                for (uint256 i = 0; i<playerList.length; i++){// 모든 참가자에 대하여
                    Player storage player = players[playerList[i]];// 참가자의 주소에 해당하는 구조체를 호출
                    if(player.predict == 1){// 무승부에 배팅한 참가자가 있다면
                        payable(playerList[i]).transfer(player.money * 8);// 배팅금의 8배 입금
                    }
                }
                uint change = address(this).balance;// 현재 컨트랙에 남은 돈
                payable(ownerAdd).transfer(change);// 소유자에게 입금
                status = true;// 게임 끝
                round += 1;// 라운드 증가
                return cnt+1;// 1 반환
            }
            else {// 플레이어의 네츄럴 점수가 더 높다면
                for (uint256 i = 0; i<playerList.length; i++){// 모든 참가자에 대하여
                    Player storage player = players[playerList[i]];// 참가자의 주소에 해당하는 구조체를 호출
                    if(player.predict == 2){// 플레이어의 승에 배팅한 참가자가 있다면
                        payable(playerList[i]).transfer(player.money * 2);// 배팅금의 2배 입금
                    }   
                }  
                uint change = address(this).balance;// 현재 컨트랙에 남은 돈
                payable(ownerAdd).transfer(change);// 소유자에게 입금
                status = true;// 게임 끝
                round += 1;// 라운드 증가
                return cnt+2;// 2 반환
            }
        }
        else {// 둘 다 네츄럴 상태가 아닐 때
            if (ownerStand > playerStand){// 소유자의 점수가 더 높다면
                for (uint256 i = 0; i<playerList.length; i++){// 모든 참가자에 대하여
                        Player storage player = players[playerList[i]];// 참가자의 주소에 해당하는 구조체를 호출
                        if(player.predict == 0){// 소유자의 승에 배팅한 참가자가 있다면
                            payable(playerList[i]).transfer(player.money * 2);// 배팅금의 2배 입금
                        }
                    }
                uint change = address(this).balance;// 현재 컨트랙에 남은 돈
                payable(ownerAdd).transfer(change);// 소유자에게 입금
                status = true;// 게임 끝
                round += 1;// 라운드 증가
                return cnt+3;// 3 반환
            }
            else if(ownerStand == playerStand){// 둘의 점수가 같다면
                for (uint256 i = 0; i<playerList.length; i++){// 모든 참가자에 대하여
                        Player storage player = players[playerList[i]];// 참가자의 주소에 해당하는 구조체를 호출
                        if(player.predict == 1){// 무승부에 배팅한 참가자가 있다면
                            payable(playerList[i]).transfer(player.money * 8);// 배팅금의 8배 입금
                        }
                    }
                uint change = address(this).balance;// 현재 컨트랙에 남은 돈
                payable(ownerAdd).transfer(change);// 소유자에게 입금
                status = true;// 게임 끝
                round += 1;// 라운드 증가
                return cnt+4;// 4 반환
            }
            else{// 플레이어의 점수가 더 높다면
                for (uint256 i = 0; i<playerList.length; i++){// 모든 참가자에 대하여
                        Player storage player = players[playerList[i]];// 참가자의 주소에 해당하는 구조체를 호출
                        if(player.predict == 2){// 플레이어 승에 배팅한 참가자가 있다면
                            payable(playerList[i]).transfer(player.money * 2);// 배팅금의 2배 입금
                        }
                    }
                uint change = address(this).balance;// 현재 컨트랙에 남은 돈
                payable(ownerAdd).transfer(change);// 소유자에게 입금
                status = true;// 게임 끝
                round += 1;// 라운드 증가
                return cnt+5;// 5 반환
            }
        }
    }
}