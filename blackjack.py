from random import shuffle#random 모듈에서 shuffle 함수를 import

card = []#카드
rank = ['Ace','2','3','4','5','6','7','8','9','10','J','K','Q']#카드 번호
suit = ['_D','_S','_H','_C']#카드 문양

def shuffleCard():
    for r in rank:#카드 번호
        for s in suit:#카드 문양
            card.append(r+s)#카드 52개를 만듦

    shuffle(card)

    return card

def devide(card):#카드 2장을 반환하는 함수
    player = []#카드 저장 배열
    for i in range(2):#2장의 카드를 선택
        player.append(card[0])#첫번째 카드를 저장
        card.pop(0)#카드에서 첫번째 카드 폐기
    return player#저장된 2장의 카드를 반환

def sumNumber(player):#저장된 카드 번호로 합한 값 반환하는 함수
    cardsum = 0#카드의 합
    cnt = 0 #ace 갯수
    for i in player:#저장된 카드에 대하여
        for s in suit:#카드 문양
            if i.find(s) >=0:#카드 문양을 찾아서
                i = i[:i.index(s)]#카드 번호만 남게 한다.

        if i == 'J' or i == 'Q' or i == 'K':#카드 번호 중 J, Q, K가 있다면
            i = 10#카드 번호를 10으로 치환
        
        if i == 'Ace':#카드 번호가 ace라면
            cnt += 1#ace의 갯수 1증가
            i = 11#카드 번호를 11으로 치환

        i = int(i)#str형식을 int로 변환

        cardsum += i#카드 번호를 cardsum에 더함

        if cardsum > 21:#카드합이 21보다 크다면
            while cardsum > 21:#카드합이 21보다 작을 때 까지
                if cnt > 0 :#ace가 있다면 11 -> 1로 바꿔줌
                    cardsum -= 9 # Ace == 1
                    cnt -= 1#ace 갯수를 1감소
                else: 
                    cardsum = 0
               
    return cardsum#카드합 반환

def hit(player, card):#한 장 더 가져가는 함수
    player.append(card[0])#셔플된 카드의 첫번째 카드를 저장
    card.pop(0)#첫번째 카드 폐기
    return player#카드 반환

def stand(player):#스탑하는 함수
    return player#카드 반환

def startGame(name, player, card):#플레이어에게 hit를 할건지 stand를 할 건지 정하는 함수
    sum = sumNumber(player)#플레이어의 점수
    print(f"{name} card : {player} score : {sum}")#플레이어의 이름과 점수를 출력
    player_Answer = input(f"{name} : hit or stand? ")#플레이어의 응답

    while player_Answer != 'stand':#응답이 stand거나 점수가 21 이상이라면 나옴
        if player_Answer == 'hit':#hit라면
            hit(player, card)#hit 함수 호출
            sum = sumNumber(player)#플레이어의 점수
            print(f"{name} : card : {player} score : {sum}")#플레이어의 이름과 점수 출력

        elif player_Answer == 'stand':#플레이어가 stand라면
            stand(player)#stand 함수 호출
            sum = sumNumber(player)#플레이어의 점수
            print(f"{name} : card : {player} score : {sum}")#점수 출력
        if sum > 0:#합이 21이하라면 (0초과라면)
            player_Answer = input(f"{name} : hit or stand? ")#플레이어의 응답
        else: break#합이 21초과라면 (0이하라면)

    return sum#점수 반환
    

card = shuffleCard()#shuffleCard 함수를 이용하여 카드 생성
print(f"card : {card}")#카드 출력
print()

player1 = (devide(card))#플레이어1에게 2장의 카드 분배
player2 = (devide(card))#플레이어2에게 2장의 카드 분배
print(f"player1 : {player1}")#플레이어1의 카드 출력
print(f"player2 : {player2}")#플레이어1의 카드 출력
print()

sum1 = startGame('player1', player1, card)#플레이어1 게임 시작
sum2 = startGame('player2', player2, card)#플레이어2 게임 시작
print(f"player1 : {sum1}")#플레이어1의 점수 반환
print(f"player2 : {sum2}")#플레이어2의 점수 반환
print()

def whoWin(sum1, sum2):
    if sum1 > sum2 : print("player1 Win")#점수 비교
    elif sum1 == sum2 : print("draw")
    else : print("player2 Win")

print(card)#카드 출력