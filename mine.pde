/*
 初級: マス目   81(num_x=num_y=9) 個、地雷 10 個 
 中級: マス目 256(num_x=num_y=16) 個、地雷 40 個
 上級: マス目 480(num_x=32,num_y=15) 個、地雷 99 個
 

 このマインスイーパーの機能
 ・数字が０のマス（すでに開けた（水色）が何も数字が書かれていないマス）なら自動で周りのマスが開く
 ・リセットできる(resetボタンかrキー）
 ・開いている数字をダブルクリックすると赤いマークを付けてない周りのマスを全て開く
*/
PrintWriter data;
String s_data;
int h[];

int i, j, gq, rx, ry, num_x, num_y, mw, go, gc, mv, df, menu;
int mass_wide = mw = 30;                                        //マスの大きさ
int mass_all_number = num_x= num_y = 9;                         //マスの個数＝num_x*num_y
int r_count = 0;                                                //地雷設置カウント
int number_mine = 10;                                           //地雷の数
int[][]mine  = new int[480+9][480+9];//mine[][]=１：周りに地雷０個、２～９：周りに地雷が１～８個,１００：地雷のあるところ、0:使用しない
int[][]pm_m = new int[480+9][480+9];                            //Pushed Mass　(クリックしたマスを記憶)
int[][]mk_m = new int[480+9][480+9];                            //MarK Mass (マークしたマスを記憶）
int value=0;                                                    //クリック処理に使用
int mark_value = mv = 0;                                        //キーを押す（マークを付ける処理に使用）
int game_over = go = 0, game_clear = gc = 0, game_quit = gq = 0;//ゲームオーバーとクリアの判定とゲーム終了の判定に使う
int reset = 1;                                                  //リセット処理に使用(1:リセットする,0:リセットしない)
int difficulty = df = 0;                                        //難易度設定
int Menu_Wide= menu = 30;                                       //メニュー欄の長さ

void setup() {
  /*size(mw*(num_x+2), mw*(num_y+2));//画面サイズ(processing2.1.1では可）*/
  surface.setResizable(true);//画面サイズ(processing3.1.1用）
  textSize(12);
  data = createWriter("back.txt");
}

void draw() {
  surface.setSize(mw*(num_x+2), mw*(num_y+2)+menu);//画面サイズ
  background(255);//背景で塗りつぶし
  /*地雷と数字の設定*/
  Reset();//リセットマスをクリックしたとき
  if (reset==1) {
    Make_Difficulty();//難易度設定
    Restart();        //初期化
    SetMine();        //地雷設置
    SetNumber();      //数字を設定
    reset=0;          //リセットの処理を繰り返さない
  }
  Show_Count();//残りの地雷の数と難易度の表示
  Judge();//ゲームオーバーorクリアの判定
  Change_Difficulty();//難易度変更を行う

  /*二重forでの処理*/
  for (i=1; i*mw<width-mw; i++) {
    for (j=1; j*mw<height-mw-menu; j++) {
      MainShow();//数字やマークを表示する
      Oncursor();//カーソルがマス上にあるときに行う処理

      /*開いたマスが地雷ならゲームオーバー*/
      if (mine[i][j]==100&&pm_m[i][j]==1) {
        go=1;
      }
    }
  }

  value=mv=0;//マス外をクリックまたはキーを押した時にvalueとmvの値を初期化
}

///////////////ここから関数//////////////////////

/*リセットする処理*/
void Reset() {
  /*リセットマスを描く*/
  rect(width-mw, height-mw, mw, mw/2);
  fill(0);
  text("reset", width-mw, height-mw/2);
  noFill();
  /*リセットマスを押すとリセットする*/
  if ( mouseX>width-mw && mouseX<width && mouseY>height-mw && mouseY<height) {
    fill(10, 50);
    rect(width-mw, height-mw, mw, mw/2);
    noFill();
    if (value==1) {
      reset=1;
    }
  }
}

/*初期化*/
void Restart() {
  for (i=1; i<=num_x; i++) {
    for (j=1; j<=num_y; j++) {
      mine[i][j]=1;
      pm_m[i][j]=0;
      mk_m[i][j]=0;
    }
  }
  gc=go=r_count=mv=value=gq=0;
}

/*地雷設置*/
void SetMine() {
  while (r_count<number_mine) {//地雷を設置し終わるまでの処理
    int rx = int (random(1, num_x+1));
    int ry = int (random(1, num_y+1));
    if (mine[rx][ry]==1) {
      mine[rx][ry]=100;
      r_count++;
    }
  }
}

/*地雷の周りの数字を設定*/
void SetNumber() {
  for (int a=-1; a<2; a++) {  
    for (int b=-1; b<2; b++) {  
      for (i=1; i<=num_x; i++) {
        for (j=1; j<=num_y; j++) {
          if (mine[i][j] == 100&&mine[i+a][j+b]!=100) {
            mine[i+a][j+b]++;
          }
        }
      }
    }
  }
}

/*クリック時の処理*/
void mouseClicked(MouseEvent e ) {
  switch(e.getButton()) {
  case LEFT://左クリック
    switch(e.getCount()) {
    case 1://ワンクリック
      value=1;
      break;
    case 2://ダブルクリック
      value=3;
      break;
    }
    break;
  case RIGHT://右クリック
    value=3;
    break;
  }
}

/*クリックしたときの処理*/
void Click_Number() {
  switch(value) {
    /*カーソルのマスを開く*/
  case 1://ワンクリック
    if (mk_m[i][j]!=2) {
      fill(30, 20);
      rect(i*mw, j*mw, mw, mw);//クリックしたときのエフェクト（点滅）
      noFill();
      pm_m[i][j]=1;
    }
    break;
    /*赤マークを着けていない周りのマスに赤マークを付ける*/
  case 2://ダブルクリック
    for (int a=-1; a<2; a++) {
      for (int b=-1; b<2; b++) {
        switch(mk_m[i+a][j+b]) {
        case 0:
          if (pm_m[i+a][j+b]==0) {
            mk_m[i+a][j+b]=2;
          }
          break;
        case 2:
          mk_m[i+a][j+b]=0;
          break;
        }
      }
    }
    break;
    /*赤マークを着けていない数字の周りのマスすべてを開ける*/
  case 3://右クリック
    for (int a=-1; a<2; a++) {
      for (int b=-1; b<2; b++) {
        if (pm_m[i+a][j+b]==0&&mk_m[i+a][j+b]!=2) {
          pm_m[i+a][j+b]=1;
          if (mine[i+a][j+b]==100) {
            go=1;
          }
        }
      }
    }
    break;
  }
  value=0;
}

/*キーを押したときの処理*/
void keyPressed() {
  if (keyPressed&&mv<3) {
    mv++;
  } else if (mv>3||mv==0) {
    mv=0;
  }
}

/*数字を表示させる処理*/
void Show_Number() {
  /*既に表示した0のマスの周りの数字を表示させる*/
  if (pm_m[i][j]==1&&mine[i][j]==1) {
    for (int a=-1; a<2; a++) {
      for (int b=-1; b<2; b++) {
        pm_m[i+a][j+b]=1;
      }
    }
  }

  /*クリックしたマスの数字を出し続ける*/
  if (pm_m[i][j]>=1) {
    gc++;
    fill(#BFFAFF);
    rect(i*mw, j*mw, mw, mw);
    noFill();
    switch(mine[i][j]) {
    case 1:
      break;
    case 100:
      if (mk_m[i][j]==2) {//マークしたところと重なるとき
        fill(0, 0, 255);//青
      } else {
        fill(255, 0, 0);//赤
      }
      rect(i*mw, j*mw, mw, mw);
      noFill();
      break;
    default:
      fill(0);
      text(mine[i][j]-1, i*mw+mw/3, j*mw+mw/1.5);
      noFill();
      break;
    }
  }
}

/*オート機能*/
void Auto() {
  ///*ランダムで空ける*/
  //int rx = int (random(1, num_x+1));
  //int ry = int (random(1, num_y+1));
  //pm_m[rx][ry]=1;
}

/*クリアとゲームオーバーの判定*/
void Judge() { 
  if (go==1 && gq==0) {//ゲームオーバーしたとき
    // Back_save();
    /*全マスの表示*/
    for (i=1; i<=num_x; i++) {
      for (j=1; j<=num_y; j++) {
        pm_m[i][j]=1;
      }
    }
    /*”ゲームオーバー”と表示*/
    textSize(20);
    fill(0);
    text("Game Over!!", width/2-mw-30, mw/2);
    noFill();
    textSize(12);
  } else if (gc>=num_x*num_y-number_mine) {//ゲームクリアしたとき（開けたマス数が、全マスから地雷マスを引いた数以上のとき）
    /*全マスの表示*/
    for (i=1; i<=num_x; i++) {
      for (j=1; j<=num_y; j++) {
        pm_m[i][j]=1;
      }
    }
    /*”ゲームクリア”と表示*/
    textSize(20);
    fill(0);
    text("Game Clear!!", width/2-mw-30, mw/2);
    noFill();
    textSize(12);
    gq=1;//クリア後にゲームオーバーにならない
  }
  gc=0;//クリアカウントを初期化
}

/*キーを押したときの処理*/
void Mark() {
  if (mv>0) {
    switch(key) {
    case 'r':
      reset=1;
      break;
    case ' ':
      if (mk_m[i][j]==0||mk_m[i][j]==1) {
        mk_m[i][j]=2;
      } else if (mk_m[i][j]==2) {
        mk_m[i][j]=0;
      }
      break;
    case 'b':
      Back_writing();
      break;
    default:/*マスにマークを付ける*/
      switch(mk_m[i][j]) {
      case 0:
        mk_m[i][j]=1;
        break;
      case 1:
        mk_m[i][j]=2;
        break;
      case 2:
        mk_m[i][j]=0;
        break;
      }
      break;
    }
    mv=0;
  }
}

/*数字とマス目とマークを描く*/
void MainShow() {
  Show_Number();//数字を表示
  rect(i*mw, j*mw, mw, mw);  //マス目を書く
  /*マークを付けたマスを表示させる*/
  switch(mk_m[i][j]) {
  case 1://薄い黄色でマークを付ける
    fill(255, 255, 0, 100);
    rect(i*mw, j*mw, mw, mw);
    noFill();
    break;
  case 2://薄い赤でマークを付ける
    fill(255, 0, 0, 100);
    rect(i*mw, j*mw, mw, mw);
    noFill();
    break;
  }
}

/*見えるカウント（地雷の残り数と難易度）を表示する*/
void Show_Count() {
  /*地雷の残り数を表示する*/
  int a =0;
  for (i=1; i*mw<width-mw; i++) {
    for (j=1; j*mw<height-mw-menu; j++) {
      if (mk_m[i][j]==2) {
        a++;
      }
    }
  }
  text("mine = " + (number_mine-a), width*0.1, 12);
  /*難易度の表示*/
  Show_Difficulty();
}

/*難易度設定 Change_Difficulty(), Make_Difficulty(), Show_Difficulty()*/
/*難易度の変更*/
void Change_Difficulty() {//rect( mw+60*i, height-mw, 60, mw/2);
  for (i=0; i<3; i++) {
    if (mouseX>mw+60*i&&mouseX<mw+60*i+60&&mouseY>height-mw&&mouseY<height-mw+mw/2) {
      text("OK", 10, 10);
      fill(10, 50);
      rect( mw+60*i, height-mw, 60, mw/2);
      noFill();
      if (value==1) {
        df=i;
        reset=1;
      }
    }
  }
}

/*難易度による数値の変更*/
void Make_Difficulty() {
  switch(df) {
  case 0://easy
    number_mine = 10;
    num_x=num_y=9;
    break;
  case 1://normal
    number_mine = 40;
    num_x =num_y= 18;
    break;
  case 2://difficult
    number_mine = 99;
    num_x = 32;
    num_y = 15;
    break;
  }
}

/*難易度選択を表示*/
void Show_Difficulty() {
  for (i=0; i<3; i++) {
    switch(i) {
    case 0:
      if (df==0) {
        fill(255, 0, 0);
      } else {
        fill(0);
      }
      text("easy", (mw+60*i)+10, height-mw+12);
      noFill();
      break;
    case 1:
      if (df==1) {
        fill(255, 0, 0);
      } else {
        fill(0);
      }
      text("normal", (mw+60*i)+10, height-mw+12);
      noFill();
      break;
    case 2:
      if (df==2) {
        fill(255, 0, 0);
      } else {
        fill(0);
      }
      text("difficult", (mw+60*i)+10, height-mw+12);
      noFill();
      break;
    }
    rect(mw+60*i, height-mw, 60, mw/2);
    noFill();
  }
}

/*カーソルがある一つのマス上にあるときの処理*/
void Oncursor() {
  if (i*mw < mouseX &&i*mw+mw > mouseX && j*mw < mouseY && j*mw+mw > mouseY ) {
    /*テスト用*/
    fill(0);
    text("i = " + i +" j = "+j + " mine[" + i + "}[" + j + "] = "+ (mine[i][j]-1)+" mv= "+
      mv+" mk_m = "+mk_m[i][j], 10, height-mw/2-20);
    noFill();

    /*カーソルが乗っているマスを薄い色で塗る（どのマスをクリックできるかを分かりやすくするため）*/
    fill(10, 50);
    rect(i*mw, j*mw, mw, mw);
    noFill();

    Click_Number();//クリック時の処理
    Mark();//マークを付ける
  }
}

/*地雷の位置をファイルに書き込む*/
//void Back_save() {
//  for (i=1; i<=num_x; i++) {
//    for (j=1; j<=num_y; j++) {
//      data.println(pm_m[i][j]+i+j);
//    }
//  }
//  data.close();
//}

/*同じ地雷配置でやり直す*/
void Back_writing() {
  for (i=1; i<=num_x; i++) {
    for (j=1; j<=num_y; j++) {
      pm_m[i][j]=0;
    }
  }
  gc=go=r_count=mv=value=gq=0;
}
