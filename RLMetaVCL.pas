unit RLMetaVCL;

interface

uses
  Windows, SysUtils, Graphics, Classes, Math, StdCtrls, 
  RLMetaFile, RLUtils, RLConsts;

type
  TPointArray=array of TPoint;
  
function  ToMetaRect(const aSource:TRect):TRLMetaRect;
function  ToMetaColor(aSource:TColor):TRLMetaColor;
function  ToMetaPenMode(aSource:TPenMode):TRLMetaPenMode;
function  ToMetaPenStyle(aSource:TPenStyle):TRLMetaPenStyle;
procedure ToMetaPen(aSource:TPen; aDest:TRLMetaPen);
function  ToMetaBrushStyle(aSource:TBrushStyle):TRLMetaBrushStyle;
procedure ToMetaBrush(aSource:TBrush; aDest:TRLMetaBrush);
function  ToMetaPoint(const aSource:TPoint):TRLMetaPoint;
function  ToMetaPointArray(const aSource:array of TPoint):TRLMetaPointArray;
function  ToMetaFontCharset(aSource:TFontCharset):TRLMetaFontCharset;
function  ToMetaFontPitch(aSource:TFontPitch):TRLMetaFontPitch;
function  ToMetaFontStyles(aSource:TFontStyles):TRLMetaFontStyles;
procedure ToMetaFont(aSource:TFont; aDest:TRLMetaFont);
function  ToMetaGraphic(aSource:TGraphic):string;
function  ToMetaTextAlignment(aSource:TAlignment):TRLMetaTextAlignment;
function  ToMetaTextLayout(aSource:TTextLayout):TRLMetaTextLayout;  
function  FromMetaRect(const aSource:TRLMetaRect):TRect;
function  FromMetaPoint(const aSource:TRLMetaPoint):TPoint;
function  FromMetaColor(const aSource:TRLMetaColor):TColor;
function  FromMetaPenMode(aSource:TRLMetaPenMode):TPenMode;
function  FromMetaPenStyle(aSource:TRLMetaPenStyle):TPenStyle;
procedure FromMetaPen(aSource:TRLMetaPen; aDest:TPen);
function  FromMetaBrushStyle(aSource:TRLMetaBrushStyle):TBrushStyle;
procedure FromMetaBrush(aSource:TRLMetaBrush; aDest:TBrush);
function  FromMetaFontStyles(aSource:TRLMetaFontStyles):TFontStyles;
function  FromMetaFontCharset(aSource:TRLMetaFontCharset):TFontCharset;
function  FromMetaFontPitch(aSource:TRLMetaFontPitch):TFontPitch;
procedure FromMetaFont(aSource:TRLMetaFont; aDest:TFont; aFactor:double=1);
function  FromMetaGraphic(const aSource:AnsiString):TGraphic;
function  FromMetaPointArray(const aSource:TRLMetaPointArray):TPointArray;
function  FromMetaTextAlignment(aSource:TRLMetaTextAlignment):TAlignment;
function  FromMetaTextLayout(aSource:TRLMetaTextLayout):TTextLayout;
//
procedure PenInflate(aPen:TPen; aFactor:double);
procedure CanvasStart(aCanvas:TCanvas);
procedure CanvasStop(aCanvas:TCanvas);
function  CanvasGetClipRect(aCanvas:TCanvas):TRect;
procedure CanvasSetClipRect(aCanvas:TCanvas; const aRect:TRect);
procedure CanvasResetClipRect(aCanvas:TCanvas);
function  CanvasGetRectData(aCanvas:TCanvas; const aRect:TRect):string;
procedure CanvasSetRectData(aCanvas:TCanvas; const aRect:TRect; const aData:AnsiString; aParity:boolean);
procedure CanvasStretchDraw(aCanvas:TCanvas; const aRect:TRect; const aData:AnsiString; aParity:boolean);
procedure CanvasTextRectEx(aCanvas:TCanvas; const aRect:TRect; aX,aY:integer; const aText:string; aAlignment:TRLMetaTextAlignment; aLayout:TRLMetaTextLayout; aTextFlags:TRLMetaTextFlags);
function  CanvasGetPixels(aCanvas:TCanvas; X,Y:integer):TColor;
procedure CanvasLineToEx(aCanvas:TCanvas; X,Y:integer);
procedure FontGetMetrics(const aFontName:AnsiString; aFontStyles:TFontStyles; var aFontRec:TRLMetaFontMetrics);
function  CanvasGetDescent(aCanvas:TCanvas):integer;

implementation

{ CONVERSION }

function ToMetaRect(const aSource:TRect):TRLMetaRect;
begin
  result.Left  :=aSource.Left;
  result.Top   :=aSource.Top;
  result.Right :=aSource.Right;
  result.Bottom:=aSource.Bottom;
end;

function ToMetaColor(aSource:TColor):TRLMetaColor;
var
  rgb:cardinal;
begin
  rgb:=ColorToRGB(aSource);
  result.Red  :=byte(rgb);
  result.Green:=byte(rgb shr 8);
  result.Blue :=byte(rgb shr 16);
end;

function ToMetaPenMode(aSource:TPenMode):TRLMetaPenMode;
begin
  case aSource of
    pmBlack      : result:=MetaPenModeBlack;
    pmWhite      : result:=MetaPenModeWhite;
    pmNop        : result:=MetaPenModeNop;
    pmNot        : result:=MetaPenModeNot;
    pmCopy       : result:=MetaPenModeCopy;
    pmNotCopy    : result:=MetaPenModeNotCopy;
    pmMergePenNot: result:=MetaPenModeMergePenNot;
    pmMaskPenNot : result:=MetaPenModeMaskPenNot;
    pmMergeNotPen: result:=MetaPenModeMergeNotPen;
    pmMaskNotPen : result:=MetaPenModeMaskNotPen;
    pmMerge      : result:=MetaPenModeMerge;
    pmNotMerge   : result:=MetaPenModeNotMerge;
    pmMask       : result:=MetaPenModeMask;
    pmNotMask    : result:=MetaPenModeNotMask;
    pmXor        : result:=MetaPenModeXor;
    pmNotXor     : result:=MetaPenModeNotXor;
  else
    result:=MetaPenModeCopy;
  end;
end;

function ToMetaPenStyle(aSource:TPenStyle):TRLMetaPenStyle;
begin
  case aSource of
    psSolid      : result:=MetaPenStyleSolid;
    psDash       : result:=MetaPenStyleDash;
    psDot        : result:=MetaPenStyleDot;
    psDashDot    : result:=MetaPenStyleDashDot;
    psDashDotDot : result:=MetaPenStyleDashDotDot;
    psClear      : result:=MetaPenStyleClear;
    psInsideFrame: result:=MetaPenStyleInsideFrame;
  else
    result:=MetaPenStyleSolid;
  end;
end;

procedure ToMetaPen(aSource:TPen; aDest:TRLMetaPen);
begin
  aDest.Color:=ToMetaColor(aSource.Color);
  aDest.Mode :=ToMetaPenMode(aSource.Mode);
  aDest.Style:=ToMetaPenStyle(aSource.Style);
  aDest.Width:=aSource.Width;
end;

function ToMetaBrushStyle(aSource:TBrushStyle):TRLMetaBrushStyle;
begin
  case aSource of
    bsSolid     : result:=MetaBrushStyleSolid;
    bsClear     : result:=MetaBrushStyleClear;
    bsHorizontal: result:=MetaBrushStyleHorizontal;
    bsVertical  : result:=MetaBrushStyleVertical;
    bsFDiagonal : result:=MetaBrushStyleFDiagonal;
    bsBDiagonal : result:=MetaBrushStyleBDiagonal;
    bsCross     : result:=MetaBrushStyleCross;
    bsDiagCross : result:=MetaBrushStyleDiagCross;
  else
    result:=MetaBrushStyleSolid;
  end;
end;

procedure ToMetaBrush(aSource:TBrush; aDest:TRLMetaBrush);
begin
  aDest.Color:=ToMetaColor(aSource.Color);
  aDest.Style:=ToMetaBrushStyle(aSource.Style);
end;

function ToMetaPoint(const aSource:TPoint):TRLMetaPoint;
begin
  result.X:=aSource.X;
  result.Y:=aSource.Y;
end;

function ToMetaPointArray(const aSource:array of TPoint):TRLMetaPointArray;
var
  i:integer;
begin
  SetLength(result,High(aSource)+1);
  for i:=0 to High(aSource) do
    result[i]:=ToMetaPoint(aSource[i]);
end;

function ToMetaFontCharset(aSource:TFontCharset):TRLMetaFontCharset;
begin
  result:=TRLMetaFontCharset(aSource);
end;

function ToMetaFontPitch(aSource:TFontPitch):TRLMetaFontPitch;
begin
  case aSource of
    fpDefault : result:=MetaFontPitchDefault;
    fpVariable: result:=MetaFontPitchVariable;
    fpFixed   : result:=MetaFontPitchFixed;
  else
    result:=MetaFontPitchDefault;
  end;
end;

function ToMetaFontStyles(aSource:TFontStyles):TRLMetaFontStyles;
begin
  result:=0;
  if fsBold in aSource then
    result:=result or MetaFontStyleBold;
  if fsItalic in aSource then
    result:=result or MetaFontStyleItalic;
  if fsUnderline in aSource then
    result:=result or MetaFontStyleUnderline;
  if fsStrikeOut in aSource then
    result:=result or MetaFontStyleStrikeOut;
end;

procedure ToMetaFont(aSource:TFont; aDest:TRLMetaFont);
begin
  aDest.PixelsPerInch:=aSource.PixelsPerInch;
  aDest.Charset      :=ToMetaFontCharset(aSource.Charset);
  aDest.Color        :=ToMetaColor(aSource.Color);
  aDest.Height       :=aSource.Height;
  aDest.Name         :=aSource.Name;
  aDest.Pitch        :=ToMetaFontPitch(aSource.Pitch);
  aDest.Size         :=aSource.Size;
  aDest.Style        :=ToMetaFontStyles(aSource.Style);
end;

function ToMetaGraphic(aSource:TGraphic):string;
var
  s:TStringStream;
  m:TBitmap;
  g:TGraphic;
begin
  m:=nil;
  s:=TStringStream.Create('');
  try
    g:=aSource;
    // identifica os tipos nativos
    if g=nil then
      s.WriteString('NIL')
    else if g is TBitmap then
      s.WriteString('BMP')
    else if g is TIcon then
      s.WriteString('ICO')
    else
    begin
      // qualquer outro formato � transformado em bmp para ficar compat�vel com um carregador de qualquer plataforma
      m:=TBitmap.Create;
      m.Width :=aSource.Width;
      m.Height:=aSource.Height;
      g:=m;
      m.Canvas.Draw(0,0,aSource);
      s.WriteString('BMP');
    end;
    if Assigned(g) then
      g.SaveToStream(s);
    result:=s.DataString;
  finally
    if Assigned(m) then
      m.free;
    s.free;
  end;
end;

function ToMetaTextAlignment(aSource:TAlignment):TRLMetaTextAlignment;
begin
  case aSource of
    taLeftJustify : result:=MetaTextAlignmentLeft;
    taRightJustify: result:=MetaTextAlignmentRight;
    taCenter      : result:=MetaTextAlignmentCenter;
  else
    if aSource=succ(taCenter) then
      result:=MetaTextAlignmentJustify
    else
      result:=MetaTextAlignmentLeft;
  end;
end;

function ToMetaTextLayout(aSource:TTextLayout):TRLMetaTextLayout;
begin
  case aSource of
    tlTop   : result:=MetaTextLayoutTop;
    tlBottom: result:=MetaTextLayoutBottom;
    tlCenter: result:=MetaTextLayoutCenter;
  else
    if aSource=succ(tlCenter) then
      result:=MetaTextLayoutJustify
    else
      result:=MetaTextLayoutTop;
  end;
end;

function FromMetaRect(const aSource:TRLMetaRect):TRect;
begin
  result.Left  :=aSource.Left;
  result.Top   :=aSource.Top;
  result.Right :=aSource.Right;
  result.Bottom:=aSource.Bottom;
end;

function FromMetaPoint(const aSource:TRLMetaPoint):TPoint;
begin
  result.X:=aSource.X;
  result.Y:=aSource.Y;
end;

function FromMetaColor(const aSource:TRLMetaColor):TColor;
begin
  result:=RGB(aSource.Red,aSource.Green,aSource.Blue);
end;

function FromMetaPenMode(aSource:TRLMetaPenMode):TPenMode;
begin
  case aSource of
    MetaPenModeBlack      : result:=pmBlack;
    MetaPenModeWhite      : result:=pmWhite;
    MetaPenModeNop        : result:=pmNop;
    MetaPenModeNot        : result:=pmNot;
    MetaPenModeCopy       : result:=pmCopy;
    MetaPenModeNotCopy    : result:=pmNotCopy;
    MetaPenModeMergePenNot: result:=pmMergePenNot;
    MetaPenModeMaskPenNot : result:=pmMaskPenNot;
    MetaPenModeMergeNotPen: result:=pmMergeNotPen;
    MetaPenModeMaskNotPen : result:=pmMaskNotPen;
    MetaPenModeMerge      : result:=pmMerge;
    MetaPenModeNotMerge   : result:=pmNotMerge;
    MetaPenModeMask       : result:=pmMask;
    MetaPenModeNotMask    : result:=pmNotMask;
    MetaPenModeXor        : result:=pmXor;
    MetaPenModeNotXor     : result:=pmNotXor;
  else
    result:=pmCopy;  
  end;
end;

function FromMetaPenStyle(aSource:TRLMetaPenStyle):TPenStyle;
begin
  case aSource of
    MetaPenStyleSolid      : result:=psSolid;
    MetaPenStyleDash       : result:=psDash;
    MetaPenStyleDot        : result:=psDot;
    MetaPenStyleDashDot    : result:=psDashDot;
    MetaPenStyleDashDotDot : result:=psDashDotDot;
    MetaPenStyleClear      : result:=psClear;
    MetaPenStyleInsideFrame: result:=psInsideFrame;
  else
    result:=psSolid;
  end;
end;

procedure FromMetaPen(aSource:TRLMetaPen; aDest:TPen);
begin
  aDest.Color:=FromMetaColor(aSource.Color);
  aDest.Mode :=FromMetaPenMode(aSource.Mode);
  aDest.Style:=FromMetaPenStyle(aSource.Style);
  aDest.Width:=aSource.Width;
end;

function FromMetaBrushStyle(aSource:TRLMetaBrushStyle):TBrushStyle;
begin
  case aSource of
    MetaBrushStyleSolid     : result:=bsSolid;
    MetaBrushStyleClear     : result:=bsClear;
    MetaBrushStyleHorizontal: result:=bsHorizontal;
    MetaBrushStyleVertical  : result:=bsVertical;
    MetaBrushStyleFDiagonal : result:=bsFDiagonal;
    MetaBrushStyleBDiagonal : result:=bsBDiagonal;
    MetaBrushStyleCross     : result:=bsCross;
    MetaBrushStyleDiagCross : result:=bsDiagCross;
  else
    result:=bsSolid;
  end;
end;

procedure FromMetaBrush(aSource:TRLMetaBrush; aDest:TBrush);
begin
  aDest.Color:=FromMetaColor(aSource.Color);
  aDest.Style:=FromMetaBrushStyle(aSource.Style);
end;

function FromMetaFontStyles(aSource:TRLMetaFontStyles):TFontStyles;
begin
  result:=[];
  if (MetaFontStyleBold and aSource)=MetaFontStyleBold then
    Include(result,fsBold);
  if (MetaFontStyleItalic and aSource)=MetaFontStyleItalic then
    Include(result,fsItalic);
  if (MetaFontStyleUnderline and aSource)=MetaFontStyleUnderline then
    Include(result,fsUnderline);
  if (MetaFontStyleStrikeOut and aSource)=MetaFontStyleStrikeOut then
    Include(result,fsStrikeOut);
end;

function FromMetaFontCharset(aSource:TRLMetaFontCharset):TFontCharset;
begin
  result:=TFontCharset(aSource);
end;

function FromMetaFontPitch(aSource:TRLMetaFontPitch):TFontPitch;
begin
  case aSource of
    MetaFontPitchDefault : result:=fpDefault;
    MetaFontPitchVariable: result:=fpVariable;
    MetaFontPitchFixed   : result:=fpFixed;
  else
    result:=fpDefault;
  end;
end;

procedure FromMetaFont(aSource:TRLMetaFont; aDest:TFont; aFactor:double=1);
var
  a,b:integer;
begin
  a:=aSource.PixelsPerInch;
  if a=0 then
    a:=ScreenPPI;
  b:=aDest.PixelsPerInch;
  if b=0 then
    b:=ScreenPPI;
  //  
  //aDest.PixelsPerInch:=aSource.PixelsPerInch;
  aDest.Charset      :=FromMetaFontCharset(aSource.Charset);
  aDest.Color        :=FromMetaColor(aSource.Color);
  //aDest.Height       :=aSource.Height;
  aDest.Name         :=aSource.Name;
  aDest.Pitch        :=FromMetaFontPitch(aSource.Pitch);
  aDest.Size         :=Round(aSource.Size*aFactor*a/b);
  aDest.Style        :=FromMetaFontStyles(aSource.Style);
end;

function FromMetaGraphic(const aSource:AnsiString):TGraphic;
var
  s:TStringStream;
  t, lSource:AnsiString;
begin
  if aSource='' then
  begin
    result:=nil
  end else begin
    t := copy(aSource,1,3);
    if t='NIL' then
      result:=nil
    else if t='BMP' then
      result:=TBitmap.Create
    else if t='ICO' then
      result:=TIcon.Create
    else
      result:=nil;

    if Assigned(result) then
    begin
      lSource := aSource;
      delete(lSource,1,3);
      s:=TStringStream.Create(lSource);
      try
        result.LoadFromStream(s);
      finally
        s.free;
      end;
    end;
  end;
end;

function FromMetaPointArray(const aSource:TRLMetaPointArray):TPointArray;
var
  i:integer;
begin
  SetLength(result,High(aSource)+1);
  for i:=0 to High(aSource) do
    result[i]:=FromMetaPoint(aSource[i]);
end;

function FromMetaTextAlignment(aSource:TRLMetaTextAlignment):TAlignment;
begin
  case aSource of
    MetaTextAlignmentLeft   : result:=taLeftJustify;
    MetaTextAlignmentRight  : result:=taRightJustify;
    MetaTextAlignmentCenter : result:=taCenter;
    MetaTextAlignmentJustify: result:=succ(taCenter);
  else
    result:=taLeftJustify;
  end;
end;

function FromMetaTextLayout(aSource:TRLMetaTextLayout):TTextLayout;
begin
  case aSource of
    MetaTextLayoutTop    : result:=tlTop;
    MetaTextLayoutBottom : result:=tlBottom;
    MetaTextLayoutCenter : result:=tlCenter;
    MetaTextLayoutJustify: result:=succ(tlCenter);
  else
    result:=tlTop;
  end;
end;

{ MISC }

procedure PenInflate(aPen:TPen; aFactor:double);
begin
  if aPen.Width>1 then
    aPen.Width:=Max(1,Trunc(aPen.Width*aFactor));
end;

procedure CanvasStart(aCanvas:TCanvas);
begin

end;

procedure CanvasStop(aCanvas:TCanvas);
begin

end;

function CanvasGetClipRect(aCanvas:TCanvas):TRect;
begin
  GetClipBox(aCanvas.Handle,result);
end;

procedure CanvasSetClipRect(aCanvas:TCanvas; const aRect:TRect);
var
  isnull:boolean;
begin
  isnull:=((aRect.Right-aRect.Left)=0) or ((aRect.Bottom-aRect.Top)=0);
  if isnull then
    SelectClipRgn(aCanvas.Handle,0)
  else
  begin
    SelectClipRgn(aCanvas.Handle,0);
    IntersectClipRect(aCanvas.Handle,aRect.Left,aRect.Top,aRect.Right,aRect.Bottom);
  end;
end;

procedure CanvasResetClipRect(aCanvas:TCanvas);
begin
  SelectClipRgn(aCanvas.Handle,0);
end;

function CanvasGetRectData(aCanvas:TCanvas; const aRect:TRect):string;
var
  graphic:TBitmap;
begin
  graphic:=TBitmap.Create;
  with graphic do
    try
      Width      :=aRect.Right-aRect.Left;
      Height     :=aRect.Bottom-aRect.Top;
      PixelFormat:=pf32bit;
      Canvas.CopyRect(Rect(0,0,Width,Height),aCanvas,aRect);
      result:=ToMetaGraphic(graphic);
    finally
      graphic.free;
    end;
end;

procedure CanvasSetRectData(aCanvas:TCanvas; const aRect:TRect; const aData:AnsiString; aParity:boolean);
var
  graphic:TGraphic;
  auxrect:TRect;
  aux    :integer;
begin
  graphic:=FromMetaGraphic(aData);
  if graphic<>nil then
    try
      auxrect:=aRect;
      if aParity then
      begin
        aux          :=(auxrect.Right-auxrect.Left) div graphic.Width;
        auxrect.Right:=auxrect.Left+aux*graphic.Width+1;
      end;
      aCanvas.StretchDraw(auxrect,graphic);
    finally
      graphic.free;
    end;
end;

procedure CanvasStretchDraw(aCanvas:TCanvas; const aRect:TRect; const aData:AnsiString; aParity:boolean);
begin
  CanvasSetRectData(aCanvas,aRect,aData,aParity);
end;

procedure CanvasTextRectEx(aCanvas:TCanvas; const aRect:TRect; aX,aY:integer; const aText:string; aAlignment:TRLMetaTextAlignment; aLayout:TRLMetaTextLayout; aTextFlags:TRLMetaTextFlags);
var
  delta,left,top,txtw,txth,wid,i:integer;
  buff:AnsiString;
begin
  buff :=AnsiSTring(aText);//bds2010
  delta:=aCanvas.TextWidth(' ') div 2;
  txtw :=aCanvas.TextWidth(String(buff)+' ');//bds2010
  txth :=aCanvas.TextHeight(String(buff)+' ');//bds2010
  case aAlignment of
    MetaTextAlignmentCenter: left:=(aRect.Left+aRect.Right-txtw) div 2+delta;
    MetaTextAlignmentRight : left:=aRect.Right-txtw+delta;
  else
    left:=aX+delta;
  end;
  case aLayout of
    MetaTextLayoutCenter: top:=(aRect.Top+aRect.Bottom-txth) div 2;
    MetaTextLayoutBottom: top:=aRect.Bottom-txth;
  else
    top:=aY;
  end;
  if aAlignment=MetaTextAlignmentJustify then
  begin
    wid:=aRect.Right-left;
    i := Length(buff);
    while (aCanvas.TextWidth(String(buff)+#32)<=wid) and IterateJustification(buff,i) do;
  end;
  if (aTextFlags and MetaTextFlagAutoSize)=MetaTextFlagAutoSize then
    aCanvas.TextOut(left,top,String(buff))//bds2010
  else
    aCanvas.TextRect(aRect,left,top,String(buff));//bds2010
end;

function CanvasGetPixels(aCanvas:TCanvas; X,Y:integer):TColor;
begin
  result:=aCanvas.Pixels[X,Y];
end;

type
  TLinePattern=record
    Count  :byte;
    Lengths:array[0..5] of byte;
  end;

const
  LinePatterns:array[TPenStyle] of TLinePattern=((Count:0;Lengths:(0,0,0,0,0,0)),  // psSolid
                                                 (Count:2;Lengths:(3,1,0,0,0,0)),  // psDash
                                                 (Count:2;Lengths:(1,1,0,0,0,0)),  // psDot
                                                 (Count:4;Lengths:(2,1,1,1,0,0)),  // psDashDot
                                                 (Count:6;Lengths:(3,1,1,1,1,1)),  // psDashDotDot
                                                 (Count:0;Lengths:(0,0,0,0,0,0)),  // psClear
                                                 (Count:0;Lengths:(0,0,0,0,0,0)),  // psInsideFrame
                                                 (Count:0;Lengths:(0,0,0,0,0,0)),  // Only for compatibility
                                                 (Count:0;Lengths:(0,0,0,0,0,0))); // Only for compatibility

procedure CanvasLineToEx(aCanvas:TCanvas; X,Y:integer);
var
  x0,y0   :integer;
  xb,yb   :integer;
  i,p,dist:integer;
  theta   :double;
  sn,cs   :double;
  patt    :^TLinePattern;
  forecl  :TColor;
  backcl  :TColor;
  width0  :integer;
  style0  :TPenStyle;
  factor  :integer;
  cli     :integer;
begin
  if (LinePatterns[aCanvas.Pen.Style].Count=0) or (aCanvas.Pen.Width<=1) then
    aCanvas.LineTo(X,Y)
  else
  begin
    style0:=aCanvas.Pen.Style;
    width0:=aCanvas.Pen.Width;
    x0    :=aCanvas.PenPos.X;
    y0    :=aCanvas.PenPos.Y;
    if X-x0=0 then
      theta:=pi/2
    else
      theta:=ArcTan((Y-y0)/(X-x0));
    sn    :=Sin(theta);
    cs    :=Cos(theta);
    dist  :=Round(Sqrt(Sqr(X-x0)+Sqr(Y-y0)));
    patt  :=@LinePatterns[aCanvas.Pen.Style];
    p     :=0;
    i     :=0;
    forecl:=aCanvas.Pen.Color;
    backcl:=aCanvas.Brush.Color;
    factor:=4*aCanvas.Pen.Width;
    aCanvas.Pen.Style:=psSolid;
    if aCanvas.Brush.Style<>bsClear then
    begin
      aCanvas.Pen.Color:=backcl;
      aCanvas.LineTo(X,Y);
    end;
    aCanvas.Pen.Color:=forecl;
    aCanvas.MoveTo(x0,y0);
    cli:=0;
    while i<dist do
    begin
      Inc(i,patt^.Lengths[p]*factor);
      if not (i<dist) then
        i:=dist;
      xb:=x0+Round(i*cs);
      yb:=y0+Round(i*sn);
      if cli=0 then
        aCanvas.LineTo(xb,yb)
      else
        aCanvas.MoveTo(xb,yb);
      cli:=1-cli;
      p  :=Succ(p) mod patt^.Count;
    end;
    aCanvas.Pen.Style:=style0;
    aCanvas.Pen.Width:=width0;
  end;
end;

procedure FontGetMetrics(const aFontName:AnsiString; aFontStyles:TFontStyles; var aFontRec:TRLMetaFontMetrics);
var
  size:integer;
  outl:POutlineTextMetric;
begin
  with TBitmap.Create do
    try
      Width :=1;
      Height:=1;
      Canvas.Font.Name :=String(aFontName);//bds2010
      Canvas.Font.Style:=aFontStyles;
      Canvas.Font.Size :=750;
      //
      size:=GetOutlineTextMetrics(Canvas.Handle,SizeOf(TOutlineTextMetric),nil);
      if size=0 then
        raise Exception.Create('Invalid font for GetOutlineTextMetrics');
      GetMem(outl,size);
      try
        outl^.otmSize:=size;
        if GetOutlineTextMetrics(Canvas.Handle,size,outl)=0 then
          raise Exception.Create('GetOutlineTextMetrics failed');
        //
        aFontRec.TrueType :=(outl^.otmTextMetrics.tmPitchAndFamily=TMPF_TRUETYPE);
        aFontRec.BaseFont :=aFontName;
        aFontRec.FirstChar:=Byte(outl^.otmTextMetrics.tmFirstChar);
        aFontRec.LastChar :=Byte(outl^.otmTextMetrics.tmLastChar);
        GetCharWidth(Canvas.Handle,aFontRec.FirstChar,aFontRec.LastChar,aFontRec.Widths[aFontRec.FirstChar]);
        //
        aFontRec.FontDescriptor.Name        :=aFontName;
        aFontRec.FontDescriptor.Styles      :='';
        if fsBold in aFontStyles then
          aFontRec.FontDescriptor.Styles:=aFontRec.FontDescriptor.Styles+'Bold';
        if fsItalic in aFontStyles then
          aFontRec.FontDescriptor.Styles:=aFontRec.FontDescriptor.Styles+'Italic';
        if fsUnderline in aFontStyles then
          aFontRec.FontDescriptor.Styles:=aFontRec.FontDescriptor.Styles+'Underline';
        if fsStrikeOut in aFontStyles then
          aFontRec.FontDescriptor.Styles:=aFontRec.FontDescriptor.Styles+'StrikeOut';
        aFontRec.FontDescriptor.Flags       :=32;
        aFontRec.FontDescriptor.FontBBox    :=outl^.otmrcFontBox;
        aFontRec.FontDescriptor.MissingWidth:=0;
        aFontRec.FontDescriptor.StemV       :=0;
        aFontRec.FontDescriptor.StemH       :=0;
        aFontRec.FontDescriptor.ItalicAngle :=outl^.otmItalicAngle;
        aFontRec.FontDescriptor.CapHeight   :=outl^.otmsCapEmHeight;
        aFontRec.FontDescriptor.XHeight     :=outl^.otmsXHeight;
        aFontRec.FontDescriptor.Ascent      :=outl^.otmTextMetrics.tmAscent;
        aFontRec.FontDescriptor.Descent     :=outl^.otmTextMetrics.tmDescent;
        aFontRec.FontDescriptor.Leading     :=outl^.otmTextMetrics.tmInternalLeading;
        aFontRec.FontDescriptor.MaxWidth    :=outl^.otmTextMetrics.tmMaxCharWidth;
        aFontRec.FontDescriptor.AvgWidth    :=outl^.otmTextMetrics.tmAveCharWidth;
      finally
        FreeMem(outl,size);
      end;
    finally
      free;
    end;
end;

function CanvasGetDescent(aCanvas:TCanvas):integer;
var
  aux:TBitmap;
  x,y:integer;
begin
  aux:=TBitmap.Create;
  try
    aux.Width      :=1;
    aux.Height     :=1;
    aux.PixelFormat:=pf32bit;
    aux.Canvas.Font.Assign(aCanvas.Font);
    aux.Canvas.Font.Style :=aux.Canvas.Font.Style-[fsUnderline];
    aux.Canvas.Font.Color :=clWhite;
    aux.Canvas.Brush.Style:=bsSolid;
    aux.Canvas.Brush.Color:=clBlack;
    aux.Width :=aux.Canvas.TextWidth('L');
    aux.Height:=aux.Canvas.TextHeight('L');
    aux.Canvas.TextOut(0,0,'L');
    //
    y:=aux.Height-1;
    while y>=0 do
    begin
      x:=0;
      while x<aux.Width do
      begin
        with TRGBArray(aux.ScanLine[y]^)[x] do
          if RGB(rgbRed,rgbGreen,rgbBlue)<>0 then
            Break;
        Inc(x);
      end;
      if x<aux.Width then
        Break;
      Dec(y);
    end;
    //
    Result:=aux.Height-1-y;
  finally
    aux.Free;
  end;
end;

end.

