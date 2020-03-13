int TimeDiff(String date1, String date2){
  
  String[] dt1 = split(date1,' ');
  String[] dt2 = split(date2,' ');
  String[] T1 = split(dt1[1],':');
  String[] T2 = split(dt2[1],':');
  String[] D1 = split(dt1[2],'.');
  String[] D2 = split(dt2[2],'.');
  
  int y1 = int(D1[2]);
  int y2 = int(D2[2]);
  int m1 = int(D1[1]);
  int m2 = int(D2[1]);
  int d1 = int(D1[0]);
  int d2 = int(D2[0]);
  
  int h1 = int(T1[0]);
  int h2 = int(T2[0]);
  int mi1 = int(T1[1]);
  int mi2 = int(T2[1]);
  
  int dayd = GetDifference(y1,m1,d1,y2,m2,d2);
  
  if(dayd == 0){
    return (60*(h2 - h1) + (mi2 - mi1));
  }else {
    dayd--;
    return (60*(24-h1+h2) + mi2 - mi1 + (dayd * 1440));
  }
}
