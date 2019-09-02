PVector[] mergeSort(PVector [] org) {
  int m = org.length/2;
  PVector[] a = Arrays.copyOfRange(org, 0, m);
  PVector[] b = Arrays.copyOfRange(org, m, org.length);
  if (a.length > 1 || b.length > 1) {
    a = mergeSort(a);
    b = mergeSort(b);
  } 
  return merge(a, b);
}

PVector[] merge( PVector[] a, PVector[] b ) {
  PVector[] c = new PVector[a.length+b.length]; 
  
  int i = 0;   //i is the current index for a
  int j = 0;   //j is the current index for b 
  int k = 0;   //k is the current index for c

  while (i < a.length && j < b.length ) {
    if (a[i].x < b[j].x || a[i].x == b[j].x && a[i].y <= b[j].y) {
      c[k] = a[i];
      i++;
    } else {
      c[k] = b[j];
      j++;
    }
    k++;
  }

  for (int v = i; v < a.length; v++) {
    c[k] = a[v];
    k++;
  }

  for (int v = j; v < b.length; v++) {
    c[k] = b[v];
    k++;
  }

  return c;
}
