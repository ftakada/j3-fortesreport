{@unit RLMetaFile - Implementa��o das classes e rotinas para manipula��o de cole��es gr�ficas. }
unit RLMetaFile;

interface

uses
  SysUtils, Contnrs, Windows, Graphics, Dialogs, Types, Classes, Math,
  RLUtils, RLConsts;

const
  MetaOrientationPortrait =1;
  MetaOrientationLandscape=2;

  MetaTextAlignmentLeft   =1;
  MetaTextAlignmentRight  =2;
  MetaTextAlignmentCenter =3;
  MetaTextAlignmentJustify=4;
                
  MetaTextLayoutTop    =1;
  MetaTextLayoutBottom =2;
  MetaTextLayoutCenter =3;
  MetaTextLayoutJustify=4;

  MetaTextFlagAutoSize      =1;
  MetaTextFlagWordWrap      =2;
  MetaTextFlagIntegralHeight=4;

  MetaBrushStyleSolid     =1;
  MetaBrushStyleClear     =2;
  MetaBrushStyleHorizontal=3;
  MetaBrushStyleVertical  =4;
  MetaBrushStyleFDiagonal =5;
  MetaBrushStyleBDiagonal =6;
  MetaBrushStyleCross     =7;
  MetaBrushStyleDiagCross =8;

  MetaFontPitchDefault =1;
  MetaFontPitchVariable=2;
  MetaFontPitchFixed   =3;

  MetaFontStyleBold     =1;
  MetaFontStyleItalic   =2;
  MetaFontStyleUnderline=4;
  MetaFontStyleStrikeOut=8;

  MetaPenModeBlack      =1;
  MetaPenModeWhite      =2;
  MetaPenModeNop        =3;
  MetaPenModeNot        =4;
  MetaPenModeCopy       =5;
  MetaPenModeNotCopy    =6;
  MetaPenModeMergePenNot=7;
  MetaPenModeMaskPenNot =8;
  MetaPenModeMergeNotPen=9;
  MetaPenModeMaskNotPen =10;
  MetaPenModeMerge      =11;
  MetaPenModeNotMerge   =12;
  MetaPenModeMask       =13;
  MetaPenModeNotMask    =14;
  MetaPenModeXor        =15;
  MetaPenModeNotXor     =16;

  MetaPenStyleSolid      =1;
  MetaPenStyleDash       =2;
  MetaPenStyleDot        =3;
  MetaPenStyleDashDot    =4;
  MetaPenStyleDashDotDot =5;
  MetaPenStyleClear      =6;
  MetaPenStyleInsideFrame=7;

const
  MAXPAGECACHE=5;

type
  TRLGraphicObject=class;
  
  TRLMetaOrientation=byte;

  TRLMetaTextFlags=word;

  TRLMetaColor=packed record
    Red,Green,Blue:byte;
  end;

  TRLMetaTextAlignment=byte;
  TRLMetaTextLayout=byte;

  TRLMetaPenMode=byte;
  TRLMetaPenStyle=byte;
  TRLMetaBrushStyle=byte;
  TRLMetaFontCharset=byte;
  TRLMetaFontStyles=byte;
  TRLMetaFontPitch=byte;

  TRLMetaRect=packed record
    Left,Top,Right,Bottom:integer;
  end;

  TRLMetaPoint=packed record
    X,Y:integer;
  end;

  TRLMetaPointArray=packed array of TRLMetaPoint;

  TRLMetaFontDescriptor=record
    Name        :AnsiString;
    Styles      :AnsiString;
    Flags       :integer;
    FontBBox    :TRect;
    MissingWidth:integer;
    StemV       :integer;
    StemH       :integer;
    ItalicAngle :integer;
    CapHeight   :integer;
    XHeight     :integer;
    Ascent      :integer;
    Descent     :integer;
    Leading     :integer;
    MaxWidth    :integer;
    AvgWidth    :integer;
  end;
  
  TRLMetaFontMetrics=record
    TrueType      :boolean;
    BaseFont      :AnsiString;
    FirstChar     :integer;
    LastChar      :integer;
    Widths        :array[0..255] of integer;
    FontDescriptor:TRLMetaFontDescriptor;
  end;

  TRLMetaPen=class
  private
    fUser :TRLGraphicObject;
    fColor:TRLMetaColor;
    fMode :TRLMetaPenMode;
    fStyle:TRLMetaPenStyle;
    fWidth:integer;
  protected
    function    GetColor:TRLMetaColor;
    procedure   SetColor(const Value:TRLMetaColor);
    function    GetWidth:integer;
    procedure   SetWidth(Value:integer);
    function    GetMode:TRLMetaPenMode;
    procedure   SetMode(Value:TRLMetaPenMode);
    function    GetStyle:TRLMetaPenStyle;
    procedure   SetStyle(Value:TRLMetaPenStyle);
  public
    constructor Create(aUser:TRLGraphicObject);
    //
    procedure   SaveToStream(aStream:TStream);
    procedure   LoadFromStream(aStream:TStream);
    //
    procedure   Assign(aObject:TRLMetaPen);
    //
    procedure   Inflate(aFactor:double);
    //
    property    Color:TRLMetaColor    read GetColor write SetColor;
    property    Mode :TRLMetaPenMode  read GetMode  write SetMode;
    property    Style:TRLMetaPenStyle read GetStyle write SetStyle;
    property    Width:integer         read GetWidth write SetWidth;
  end;

  TRLMetaBrush=class
  private
    fUser :TRLGraphicObject;
    fColor:TRLMetaColor;
    fStyle:TRLMetaBrushStyle;
  protected
    function    GetStyle:TRLMetaBrushStyle;
    procedure   SetStyle(Value:TRLMetaBrushStyle);
    function    GetColor:TRLMetaColor;
    procedure   SetColor(const Value:TRLMetaColor);
  public
    constructor Create(aUser:TRLGraphicObject);
    //
    procedure   SaveToStream(aStream:TStream);
    procedure   LoadFromStream(aStream:TStream);
    //
    procedure   Assign(aObject:TRLMetaBrush);
    //
    property    Color:TRLMetaColor      read GetColor write SetColor;
    property    Style:TRLMetaBrushStyle read GetStyle write SetStyle;
  end;

  TRLMetaFont=class
  private
    fUser         :TRLGraphicObject;
    fPixelsPerInch:integer;
    fCharset      :TRLMetaFontCharset;
    fColor        :TRLMetaColor;
    fHeight       :integer;
    fNameId       :integer;
    fPitch        :TRLMetaFontPitch;
    fSize         :integer;
    fStyle        :TRLMetaFontStyles;
  protected
    function    GetName:String;
    procedure   SetName(const Value:String);
    function    GetCharset:TRLMetaFontCharset;
    procedure   SetCharset(Value:TRLMetaFontCharset);
    function    GetColor:TRLMetaColor;
    procedure   SetColor(const Value:TRLMetaColor);
    function    GetStyle:TRLMetaFontStyles;
    procedure   SetStyle(Value:TRLMetaFontStyles);
    function    GetSize:integer;
    procedure   SetSize(Value:integer);
    function    GetPixelsPerInch:integer;
    procedure   SetPixelsPerInch(Value:integer);
    function    GetPitch:TRLMetaFontPitch;
    procedure   SetPitch(Value:TRLMetaFontPitch);
    function    GetHeight:integer;
    procedure   SetHeight(Value:integer);
  public
    constructor Create(aUser:TRLGraphicObject);
    //
    procedure   SaveToStream(aStream:TStream);
    procedure   LoadFromStream(aStream:TStream);
    //
    procedure   Assign(aObject:TRLMetaFont);
    //
    property    PixelsPerInch:integer           read GetPixelsPerInch write SetPixelsPerInch;
    property    Charset      :TRLMetaFontCharset read GetCharset       write SetCharset;
    property    Color        :TRLMetaColor       read GetColor         write SetColor;
    property    Height       :integer           read GetHeight        write SetHeight;
    property    Name         :String            read GetName          write SetName;
    property    Pitch        :TRLMetaFontPitch   read GetPitch         write SetPitch;
    property    Size         :integer           read GetSize          write SetSize;
    property    Style        :TRLMetaFontStyles  read GetStyle         write SetStyle;
  end;

  TRLGraphicStorage=class;
  TRLGraphicSurface=class;
  TRLGraphicObjectClass=class of TRLGraphicObject;

  {@class TRLGraphicStorage - Cole��o de p�ginas ou superf�cies de desenho. }
  TRLGraphicStorage=class(TComponent)
  private
    // cache para p�ginas em mem�ria
    fPageCache     :TObjectList;
    // endere�o das p�ginas em disco (stream)
    fPageAllocation:TList;
    // arquivo tempor�rio para armazenamento das p�ginas
    fTempStream    :TStream;
    fTempFileName  :String;
    // vers�o do arquivo carregado que indica tamb�m o formato da grava��o
    fFileVersion   :integer;
    // metas�mbolos
    fMacros        :TStrings;
    // lista de refer�ncias � este objeto. quando n�o houver mais refer�ncias, o objeto � destru�do
    fReferenceList :TList;
    // guarda refer�ncia � p�gina no cache em mem�ria
    procedure   AddToCache(aSurface:TRLGraphicSurface);
    // retorna refer�ncia � p�gina se ela estiver no cache em mem�ria
    function    GetFromCache(aPageIndex:integer):TRLGraphicSurface;
    // atualiza pend�ncias do cache em disco
    procedure   FlushCache;
    // instancia p�gina e carrega do disco
    function    LoadPageFromDisk(aPageIndex:integer):TRLGraphicSurface;
    // retorna refer�ncia � p�gina quer esteja em disco ou cach�
    function    GetPages(aPageIndex:integer):TRLGraphicSurface;
    // retorna a quantidade de p�ginas estocadas
    function    GetPageCount: integer;
    // for�a a cria��o do arquivo tempor�rio
    procedure   TempStreamNeeded;
    // recupera a p�gina do espa�o tempor�rio em disco
    procedure   RetrievePage(aSurface:TRLGraphicSurface);
    // policia o n�mero da vers�o para grava��o
    procedure   SetFileVersion(aVersion:integer);
    // getters e setters de s�mbolos especiais
    function    GetFirstPageNumber: integer;
    function    GetHeight: integer;
    function    GetLastPageNumber: integer;
    function    GetOrientation: TRLMetaOrientation;
    function    GetPaperHeight: double;
    function    GetPaperWidth: double;
    function    GetTitle: String;
    function    GetWidth: integer;
    function    GetOrientedHeight: integer;
    function    GetOrientedPaperHeight: double;
    function    GetOrientedPaperWidth: double;
    function    GetOrientedWidth: integer;
    procedure   SetFirstPageNumber(const Value: integer);
    procedure   SetLastPageNumber(const Value: integer);
    procedure   SetOrientation(const Value: TRLMetaOrientation);
    procedure   SetPaperHeight(const Value: double);
    procedure   SetPaperWidth(const Value: double);
    procedure   SetTitle(const Value: String);
    procedure SetHeight(const Value: integer);
    procedure SetWidth(const Value: integer);
  protected
    procedure   Notification(aComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(aOwner:TComponent); override;
    destructor  Destroy; override;

    {@method Link - Cria uma refer�ncia para o componente.
     A inst�ncia � mantida at� que n�o haja mais refer�ncias a ela. :/}
    procedure   Link(aComponent:TComponent);

    {@method Unlink - Retira refer�ncia para o componente.
     Quando n�o houver mais refer�ncias, a inst�ncia � automaticamente liberada. :/}
    procedure   Unlink(aComponent:TComponent=nil);

    {@method Add - Adiciona p�gina � cole��o. :/}
    procedure   Add(aSurface:TRLGraphicSurface);

    {@method New - Adiciona p�gina � cole��o. :/}
    function    New(PaperWidth, PaperHeight: integer): TRLGraphicSurface;

    {@method Update - Atualiza dados da p�gina em disco. :/}
    procedure   Update(aSurface:TRLGraphicSurface);

    {@method Clear - Libera todas as p�ginas da mem�ria e do cach�. :/}
    procedure   Clear;

    {@method SaveToFile - Salva p�ginas para uma arquivo em disco. :/}
    procedure   SaveToFile(const aFileName:String);
    
    {@method LoadFromFile - Carrega p�ginas de um arquivo em disco. :/}
    procedure   LoadFromFile(const aFileName:String);

    {@method SaveToStream - Salva p�ginas em uma stream. :/}
    procedure   SaveToStream(aStream:TStream);

    {@method LoadFromStream - Carrega p�ginas de uma stream. :/}
    procedure   LoadFromStream(aStream:TStream);

    {@prop Pages - Retorna p�gina pelo �ndice. :/}
    property    Pages[aPageIndex:integer]:TRLGraphicSurface read GetPages; default;

    {@prop PageCount - Retorna a quantidade p�ginas armazenadas. :/}
    property    PageCount:integer read GetPageCount;

    {@prop FileVersion - Indica vers�o do relat�rio carregado ou determina a vers�o do arquivo a ser gravado.
     Esta prop pode ser utilizada para converter arquivos de uma vers�o para outra, bastando para isso, carregar
     o arquivo, alterar a sua vers�o e salv�-lo novamente. :/}
    property    FileVersion:integer read fFileVersion write SetFileVersion;

    {@prop Macros - Lista de s�mbolos para tradu��o em tempo de visualiza��o ou impress�o. :/}
    property    Macros:TStrings read fMacros;

    {@prop FirstPageNumber - Numera��o para a primeira p�gina.
     Este n�mero � normalmente 1, mas o relat�rio pode ser parte de uma encaderna��o maior e por isso ter uma
     numera��o intercalada. :/}
    property    FirstPageNumber    :integer            read GetFirstPageNumber     write SetFirstPageNumber;

    {@prop LastPageNumber - N�mero da �ltima p�gina. :/}
    property    LastPageNumber     :integer            read GetLastPageNumber      write SetLastPageNumber;

    {@prop Title - T�tulo do relat�rio. :/}
    property    Title              :String             read GetTitle               write SetTitle;

    {@prop Orientation - Orienta��o do papel. :/}
    property    Orientation        :TRLMetaOrientation read GetOrientation         write SetOrientation;

    {@prop PaperWidth - Largura do papel em mil�metros. :/}
    property    PaperWidth         :double             read GetPaperWidth          write SetPaperWidth;

    {@prop PaperHeight - Altura do papel em mil�metros. :/}
    property    PaperHeight        :double             read GetPaperHeight         write SetPaperHeight;

    {@prop OrientedPaperWidth - Largura do papel orientado para leitura em mil�metros. :/}
    property    OrientedPaperWidth :double  read GetOrientedPaperWidth;

    {@prop OrientedPaperHeight - Altura do papel orientado para leitura em mil�metros. :/}
    property    OrientedPaperHeight:double  read GetOrientedPaperHeight;

    {@prop OrientedWidth - Largura da superf�cie orientada para leitura em pixels. :/}
    property    OrientedWidth      :integer read GetOrientedWidth;

    {@prop OrientedHeight - Altura da superf�cie orientada para leitura em pixels. :/}
    property    OrientedHeight     :integer read GetOrientedHeight;

    {@prop Width - Largura da superf�cie em pixels. :/}
    property    Width:integer read GetWidth write SetWidth;

    {@prop Height - Altura da superf�cie em pixels. :/}
    property    Height:integer read GetHeight write SetHeight;
  end;
  {/@class}

  {@class TRLGraphicSurface - Superf�cie de desenho.
   Assemelha-se ao TCanvas e, embora n�o haja qualquer rela��o hier�rquica, contempla a maioria de seus m�todos de
   desenho. }
  TRLGraphicSurface=class
  private
    // refer�ncia ao estoque. o estoque ser� avisado sempre que uma p�gina for detru�da para que seja exclu�da do cach� 
    fStorage    :TRLGraphicStorage;
    // �ndice da p�gina
    fPageIndex  :integer;
    // lista de objetos gr�ficos
    fObjects    :TObjectList;
    // posi��o do cursor (caneta)
    fPenPos     :TPoint;
    // largura, altura e orienta��o
    fWidth      :integer;
    fHeight     :integer;
    // prop de desenho atuais
    fBrush      :TBrush;
    fFont       :TFont;
    fPen        :TPen;
    // margens para write e writeln
    fMargins    :TRect;
    // indica se algo foi desenhado
    fOpened     :boolean;
    fModified   :boolean;
    // bitmap auxiliar para c�lculo de tamanho de fontes
    fBitmapAux  :TBitmap;
    // cole��o de fontes
    fFonts      :TStrings;
    // controle de clipping
    fClipStack  :TList;
    fClipRect   :TRect;
    // para livre uso
    fTag        :integer;
    // identificador de grupo e gerador
    fGeneratorId:integer;
    // metas�mbolos
    fMacros        :TStrings;
    // retorna a quantidade de objetos inclu�dos
    function    GetObjectCount:integer;
    // refer�ncia ao objeto pelo �ndice
    function    GetObjects(aIndex:integer):TRLGraphicObject;
    // muda as props de desenho
    procedure   SetBrush(const Value:TBrush);
    procedure   SetFont(const Value:TFont);
    procedure   SetPen(const Value:TPen);
    // desenho a n�vel de pontos
    function    GetPixels(X,Y:integer):TColor;
    procedure   SetPixels(X,Y:integer; const Value:TColor);
    //
    procedure   SetStorage(aStorage:TRLGraphicStorage);
    // for�a instancia��o do bitmap auxiliar 
    procedure   BitmapAuxNeeded;
    // empilha o ret�ngulo de corte 
    procedure   PushClipRect(const aRect:TRect);
    // desempilha o ret�ngulo de corte
    procedure   PopClipRect(var aRect:TRect);
    // persist�ncia de s�mbolos
    function    GetOrientation: TRLMetaOrientation;
    procedure   SetOrientation(const Value: TRLMetaOrientation);
    function    GetPaperHeight: double;
    function    GetPaperWidth: double;
    procedure   SetPaperHeight(const Value: double);
    procedure   SetPaperWidth(const Value: double);
    function    GetOrientedPaperHeight: double;
    function    GetOrientedPaperWidth: double;
    function    GetOrientedHeight: integer;
    function    GetOrientedWidth: integer;
  public
    constructor Create;
    destructor  Destroy; override;

    {@method SaveToFile - Salva os dados da p�gina em um arquivo. :/}
    procedure   SaveToFile(const aFileName:String);

    {@method LoadFromFile - Restaura os dados da p�gina de um arquivo. :/}
    procedure   LoadFromFile(const aFileName:String);

    {@method SaveToStream - Salva os dados da p�gina em uma stream. :/}
    procedure   SaveToStream(aStream:TStream);

    {@method LoadFromStream - Carrega os dados da p�gina de uma stream. :/}
    procedure   LoadFromStream(aStream:TStream);

    {@method FindFreeRow - Retorna a altura neutra mais pr�xima da coordenada informada, aonde nenhum texto � cortado. :/}
    function    FindFreeRow(aNearRow:integer; var aRow:integer):boolean;

    {@method TextWidth - Retorna a largura do texto de acordo com a fonte atual. :/}
    function    TextWidth(const aText:String):integer;
    
    {@method TextHeight - Retorna a altura do texto de acordo com a fonte atual. :/}
    function    TextHeight(const aText:String):integer;

    {@method MoveTo - Posiciona o cursor de desenho e escrita. :/}
    procedure   MoveTo(aX,aY:integer);

    {@method LineTo - Tra�a uma linha reta ligando a posi��o atual do cursor �s coordenadas passadas. :/}
    procedure   LineTo(aX,aY:integer);
    
    {@method Rectangle - Desenha um ret�ngulo. :}
    procedure   Rectangle(aLeft,aTop,aRight,aBottom:integer); overload;
    procedure   Rectangle(const aRect:TRect); overload;
    {/@method}

    {@method Ellipse - Desenha uma ellipse. :}
    procedure   Ellipse(aX1,aY1,aX2,aY2:integer); overload;
    procedure   Ellipse(const aRect:TRect); overload;
    {/@method}

    {@method Polygon - Desenha um pol�gono. :/}
    procedure   Polygon(const aPoints:array of TPoint);
    
    {@method Polyline - Desenha uma s�rie de linhas ligando os pontos passados. :/}
    procedure   Polyline(const aPoints:array of TPoint);

    {@method Write - Escreve um texto na posi��o atual do cursor. :/}
    procedure   Write(const aText:AnsiString);

    {@method WriteLn - Escreve um texto na posi��o atual do cursor e salta para a linha seguinte. :/}
    procedure   WriteLn(const aText:AnsiString);

    {@method TextOut - Escreve um texto na posi��o informada. :}
    procedure   TextOut(aLeft,aTop:integer; const aText:AnsiString);
    procedure   TextOutEx(aLeft,aTop:integer; const aText:AnsiString; aTextFlags:TRLMetaTextFlags);
    {/@method}

    {@method TextRect - Escreve um texto delimitado pelo ret�ngulo informado. :}
    procedure   TextRect(const aRect:TRect; aLeft,aTop:integer; const aText:AnsiString);
    procedure   TextRectEx(const aRect:TRect; aLeft,aTop:integer; const aText:AnsiString; aAlignment:TRLMetaTextAlignment; aLayout:TRLMetaTextLayout; aTextFlags:TRLMetaTextFlags);
    {/@method}

    {@method FillRect - Preenche um ret�ngulo com os padr�es definidos na prop Brush. :/}
    procedure   FillRect(const aRect:TRect);
    
    {@method Draw - Desenha a imagem nas coordenadas indicadas mantendo seu tamanho e propor��o. :}
    procedure   Draw(aX,aY:integer; aGraphic:TGraphic; aParity:boolean=false); overload;
    procedure   Draw(aX,aY:integer; aSurface:TRLGraphicSurface); overload;
    {/@method}

    {@method StretchDraw - Desenha uma imagem alterando caracter�sticas de modo a preencher todo o ret�ngulo. :}
    procedure   StretchDraw(const aRect:TRect; aGraphic:TGraphic; aParity:boolean=false); overload;
    procedure   StretchDraw(const aRect:TRect; aSurface:TRLGraphicSurface); overload;
    {/@method}

    {@method ScaleDraw - Desenha uma imagem contida num ret�ngulo respeitando suas propor��es. :}
    procedure   ScaleDraw(const aRect:TRect; aGraphic:TGraphic; aCenter:boolean); overload;
    procedure   ScaleDraw(const aRect:TRect; aSurface:TRLGraphicSurface; aCenter:boolean); overload;
    {/@method}

    {@method ClipDraw - Desenha um corte de uma imagem de modo a interceptar o ret�ngulo. :}
    procedure   ClipDraw(const aRect:TRect; aGraphic:TGraphic; aCenter:boolean); overload;
    procedure   ClipDraw(const aRect:TRect; aSurface:TRLGraphicSurface; aCenter:boolean); overload;
    {/@method}

    {@method CopyRect - Copia os objetos que interceptam o ret�ngulo para uma outra superf�cie. :}
    procedure   CopyRect(const aDest:TRect; aCanvas:TCanvas; const aSource:TRect); overload;
    procedure   CopyRect(const aDest:TRect; aSurface:TRLGraphicSurface; const aSource:TRect); overload;
    {/@method}

    {@method SetClipRect - Determina um novo ret�ngulo de corte para desenho e retorna a defini��o antiga. :/}
    procedure   SetClipRect(const aRect:TRect);

    {@method ResetClipRect - Anula o ret�ngulo de corte para desenho. :/}
    procedure   ResetClipRect;

    {@method Open - Inicializa a superf�cie. :/}
    procedure   Open;

    {@method Close - Finaliza a superf�cie e apaga tudo o que foi feito. :/}
    procedure   Close;
    
    {@method Clear - Libera todos os objetos e fontes da p�gina e reposiciona a caneta. :/}
    procedure   Clear;

    {@method PaintTo - Desenha a superf�cie em um Canvas com fator de escala definido pelas rela��es entre o ret�ngulo
     passado e as dimens�es da superf�cie. :/}
    procedure   PaintTo(aCanvas:TCanvas; aRect:TRect);

    {@method PageIndex - Retorna o �ndice da p�gina na lista. :/}
    property    PageIndex:integer read fPageIndex;

    {@prop Opened - Indica se a superf�cie j� foi aberta. :/}
    property    Opened   :boolean read fOpened;

    {@prop Modified - Indica se a superf�cie foi modificada. :/}
    property    Modified:boolean read fModified write fModified;

    {@prop Objects - Vetor de objetos da superf�cie. :/}
    property    Objects[aIndex:integer]:TRLGraphicObject read GetObjects;

    {@prop ObjectCount - Quantidade de objetos na superf�cie. :/}
    property    ObjectCount:integer read GetObjectCount;

    {@prop Brush - Padr�o utilizado para preenchimentos. :/}
    property    Brush  :TBrush  read fBrush   write SetBrush;

    {@prop Pen - Padr�o utilizado para linhas. :/}
    property    Pen    :TPen    read fPen     write SetPen;

    {@prop Font - Fonte padr�o para escrita. :/}
    property    Font   :TFont   read fFont    write SetFont;

    {@prop Pixels - Matriz de pontos. :/}
    property    Pixels[X,Y:integer]:TColor read GetPixels write SetPixels;

    {@prop Width - Largura da superf�cie em pixels. :/}
    property    Width  :integer read fWidth   write fWidth;

    {@prop Height - Altura da superf�cie em pixels. :/}
    property    Height :integer read fHeight  write fHeight;

    {@prop Orientation - Orienta��o da superf�cie. :/}
    property    Orientation:TRLMetaOrientation read GetOrientation write SetOrientation;

    {@prop PaperWidth - Largura do papel em mil�metros. :/}
    property    PaperWidth :double read GetPaperWidth  write SetPaperWidth;

    {@prop PaperHeight - Altura do papel em mil�metros. :/}
    property    PaperHeight:double read GetPaperHeight write SetPaperHeight;

    {@prop OrientedPaperWidth - Largura do papel orientado para leitura em mil�metros. :/}
    property    OrientedPaperWidth :double  read GetOrientedPaperWidth;

    {@prop OrientedPaperHeight - Altura do papel orientado para leitura em mil�metros. :/}
    property    OrientedPaperHeight:double  read GetOrientedPaperHeight;

    {@prop OrientedWidth - Largura da superf�cie orientada para leitura em pixels. :/}
    property    OrientedWidth :integer read GetOrientedWidth;

    {@prop OrientedHeight - Altura da superf�cie orientada para leitura em pixels. :/}
    property    OrientedHeight:integer read GetOrientedHeight;

    {@prop PenPos - Posi��o atual do cursor. :/}
    property    PenPos :TPoint  read fPenPos  write fPenPos;

    {@prop Margins - Margens de texto para uso com os m�todos: Write e WriteLn. :/}
    property    Margins:TRect   read fMargins write fMargins;

    {@prop ClipRect - Ret�ngulo de corte atual. :/}
    property    ClipRect:TRect  read fClipRect;

    {@prop Tag - Inteiro associado � superf�cie.
     N�o tem significado para o sistema e pode ser livremente utilizado pelo usu�rio.
     Nota: Esta prop n�o � armazenada em disco. :/}
    property    Tag    :integer read fTag     write fTag;

    {@prop Fonts - Lista de fontes utilizadas. :/}
    property    Fonts:TStrings read fFonts;

    {@prop GeneratorId - Identifica o objeto gerador para os pr�ximos elementos gr�ficos. :/}
    property    GeneratorId:integer read fGeneratorId write fGeneratorId;

    {@prop Storage - Refer�ncia para o estoque ao qual pertence � superf�cie gr�fica. :/}
    property    Storage:TRLGraphicStorage read fStorage;

    {@prop Macros - Lista de s�mbolos para tradu��o em tempo de visualiza��o ou impress�o. :/}
    property    Macros:TStrings read fMacros;
  end;
  {/@class}

  {@class TRLGraphicObject - Objeto primitivo de desenho. }
  TRLGraphicObject=class
  private
    fSurface       :TRLGraphicSurface;
    //
    fBoundsRect    :TRLMetaRect;
    fGroupId       :integer;
    fGeneratorId   :integer;
    fTag           :integer;
  public
    constructor Create(aSurface:TRLGraphicSurface); virtual;
    destructor  Destroy; override;

    {@method SaveToStream - Salva os dados do objeto em uma stream. :/}
    procedure   SaveToStream(aStream:TStream); dynamic;

    {@method LoadFromStream - Carrega os dados do objeto de uma stream. :/}
    procedure   LoadFromStream(aStream:TStream); dynamic;

    {@method Clone - Instancia um novo objeto com caracter�sticas semelhantes. :/}
    function    Clone(aSurface:TRLGraphicSurface):TRLGraphicObject;

    {@method PaintTo - Desenha o objeto em um canvas com os fatores de escala passados. :/}
    procedure   PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); dynamic; abstract;

    {@method Assign - Assume as caracter�sticas de um outro objeto. :/}
    procedure   Assign(aObject:TRLGraphicObject); dynamic;
    
    {@method Offset - Desloca as coordenadas do objeto. :/}
    procedure   Offset(aXDesloc,aYDesloc:integer); dynamic;

    {@method Inflate - Redimensiona o controle de acordo com os fatores passados. :/}
    procedure   Inflate(aXFactor,aYFactor:double); dynamic;

    {@prop BoundsRect - Dimens�es do objeto. :/}
    property    BoundsRect:TRLMetaRect read fBoundsRect write fBoundsRect;

    {@prop GroupId - �ndice de grupo. Os elementos gr�ficos gerados na mesma opera��o t�m o mesmo GroupId. :/}
    property    GroupId:integer read fGroupId write fGroupId;

    {@prop GeneratorId - Identifica o objeto gerador do elemento gr�fico. :/}
    property    GeneratorId:integer read fGeneratorId write fGeneratorId;

    {@prop Tag - Inteiro associado ao objeto.
     N�o tem significado para o sistema e pode ser livremente utilizado pelo usu�rio.
     Nota: Esta prop n�o � armazenada em disco. :/}
    property    Tag       :integer     read fTag        write fTag;

    {@prop Surface - Refer�ncia para a superf�cie gr�fica � qual pertence o objeto. :/}
    property    Surface   :TRLGraphicSurface read fSurface;
  end;
  {/@class}

  { TRLPixelObject }

  TRLPixelObject=class(TRLGraphicObject)
  private
    fColor:TRLMetaColor;
  public
    constructor Create(aSurface:TRLGraphicSurface); override;
    //
    procedure   SaveToStream(aStream:TStream); override;
    procedure   LoadFromStream(aStream:TStream); override;
    //
    procedure   PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
    procedure   Assign(aObject: TRLGraphicObject); override;
    //
    property    Color:TRLMetaColor read fColor write fColor;
  end;

  { TRLLineObject }

  TRLLineObject=class(TRLGraphicObject)
  private
    fFromPoint:TRLMetaPoint;
    fToPoint  :TRLMetaPoint;
    fPen      :TRLMetaPen;
    fBrush    :TRLMetaBrush;
    //
    procedure   SetPen(Value:TRLMetaPen);
    procedure   SetBrush(Value:TRLMetaBrush);
  public
    constructor Create(aSurface:TRLGraphicSurface); override;
    destructor  Destroy; override;
    //
    procedure   SaveToStream(aStream:TStream); override;
    procedure   LoadFromStream(aStream:TStream); override;
    //
    procedure   PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
    procedure   Assign(aObject: TRLGraphicObject); override;
    procedure   Offset(aXDesloc, aYDesloc: integer); override;
    procedure   Inflate(aXFactor,aYFactor:double); override;
    //
    property    FromPoint:TRLMetaPoint read fFromPoint write fFromPoint;
    property    ToPoint  :TRLMetaPoint read fToPoint   write fToPoint;
    property    Pen      :TRLMetaPen   read fPen       write SetPen;
    property    Brush    :TRLMetaBrush read fBrush     write SetBrush;
  end;

  { TRLRectangleObject }

  TRLRectangleObject=class(TRLGraphicObject)
  private
    fPen  :TRLMetaPen;
    fBrush:TRLMetaBrush;
    //
    procedure   SetPen(Value:TRLMetaPen);
    procedure   SetBrush(Value:TRLMetaBrush);
  public
    constructor Create(aSurface:TRLGraphicSurface); override;
    destructor  Destroy; override;
    //
    procedure   SaveToStream(aStream:TStream); override;
    procedure   LoadFromStream(aStream:TStream); override;
    //
    procedure   PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
    procedure   Assign(aObject: TRLGraphicObject); override;
    procedure   Inflate(aXFactor,aYFactor:double); override;
    //
    property    Pen  :TRLMetaPen   read fPen   write SetPen;
    property    Brush:TRLMetaBrush read fBrush write SetBrush;
  end;

  { TRLTextObject }

  TRLTextObject=class(TRLGraphicObject)
  private
    fBrush    :TRLMetaBrush;
    fFont     :TRLMetaFont;
    fText     :AnsiString;
    fOrigin   :TRLMetaPoint;
    fAlignment:TRLMetaTextAlignment;
    fLayout   :TRLMetaTextLayout;
    fTextFlags:TRLMetaTextFlags;
    //
    procedure   TranslateMacros(var aText:String);
    //
    procedure   SetBrush(Value:TRLMetaBrush);
    procedure   SetFont(Value:TRLMetaFont);
    function    GetDisplayText:AnsiString;
  public
    constructor Create(aSurface:TRLGraphicSurface); override;
    destructor  Destroy; override;
    //
    procedure   SaveToStream(aStream:TStream); override;
    procedure   LoadFromStream(aStream:TStream); override;
    //
    procedure   PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
    procedure   Assign(aObject: TRLGraphicObject); override;
    procedure   Offset(aXDesloc, aYDesloc: integer); override;
    procedure   Inflate(aXFactor,aYFactor:double); override;
    //                  
    property    Alignment:TRLMetaTextAlignment read fAlignment  write fAlignment;
    property    Brush    :TRLMetaBrush         read fBrush      write SetBrush;
    property    Font     :TRLMetaFont          read fFont       write SetFont;
    property    Layout   :TRLMetaTextLayout    read fLayout     write fLayout;
    property    Origin   :TRLMetaPoint         read fOrigin     write fOrigin;
    property    Text     :AnsiString               read fText       write fText;
    property    TextFlags:TRLMetaTextFlags     read fTextFlags  write fTextFlags;
    //
    property    DisplayText:AnsiString read GetDisplayText;
  end;

  { TRLFillRectObject }

  TRLFillRectObject=class(TRLGraphicObject)
  private
    fBrush:TRLMetaBrush;
    //
    procedure   SetBrush(Value:TRLMetaBrush);
  public
    constructor Create(aSurface:TRLGraphicSurface); override;
    destructor  Destroy; override;
    //
    procedure   SaveToStream(aStream:TStream); override;
    procedure   LoadFromStream(aStream:TStream); override;
    //
    procedure   PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
    procedure   Assign(aObject: TRLGraphicObject); override;
    //
    property    Brush:TRLMetaBrush read fBrush write SetBrush;
  end;

  { TRLEllipseObject }

  TRLEllipseObject=class(TRLGraphicObject)
  private
    fPen  :TRLMetaPen;
    fBrush:TRLMetaBrush;
    //
    procedure   SetPen(Value:TRLMetaPen);
    procedure   SetBrush(Value:TRLMetaBrush);
  public
    constructor Create(aSurface:TRLGraphicSurface); override;
    destructor  Destroy; override;
    //
    procedure   SaveToStream(aStream:TStream); override;
    procedure   LoadFromStream(aStream:TStream); override;
    //
    procedure   PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
    procedure   Assign(aObject: TRLGraphicObject); override;
    procedure   Inflate(aXFactor,aYFactor:double); override;
    //
    property    Pen  :TRLMetaPen   read fPen   write SetPen;
    property    Brush:TRLMetaBrush read fBrush write SetBrush;
  end;

  { TRLPolygonObject }

  TRLPolygonObject=class(TRLGraphicObject)
  private
    fPen   :TRLMetaPen;
    fBrush :TRLMetaBrush;
    fPoints:TRLMetaPointArray;
    //
    procedure   SetPen(Value:TRLMetaPen);
    procedure   SetBrush(Value:TRLMetaBrush);
  public
    constructor Create(aSurface:TRLGraphicSurface); override;
    destructor  Destroy; override;
    //
    procedure   SaveToStream(aStream:TStream); override;
    procedure   LoadFromStream(aStream:TStream); override;
    //
    procedure   PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
    procedure   Assign(aObject: TRLGraphicObject); override;
    procedure   Offset(aXDesloc, aYDesloc: integer); override;
    procedure   Inflate(aXFactor,aYFactor:double); override;
    //
    property    Pen   :TRLMetaPen      read fPen    write SetPen;
    property    Brush :TRLMetaBrush    read fBrush  write SetBrush;
    property    Points:TRLMetaPointArray read fPoints write fPoints;
  end;

  { TRLPolylineObject }

  TRLPolylineObject=class(TRLGraphicObject)
  private
    fPen   :TRLMetaPen;
    fPoints:TRLMetaPointArray;
    //
    procedure   SetPen(Value:TRLMetaPen);
  public
    constructor Create(aSurface:TRLGraphicSurface); override;
    destructor  Destroy; override;
    //
    procedure   SaveToStream(aStream:TStream); override;
    procedure   LoadFromStream(aStream:TStream); override;
    //
    procedure   PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
    procedure   Assign(aObject: TRLGraphicObject); override;
    procedure   Offset(aXDesloc, aYDesloc: integer); override;
    procedure   Inflate(aXFactor,aYFactor:double); override;
    //
    property    Pen   :TRLMetaPen      read fPen    write SetPen;
    property    Points:TRLMetaPointArray read fPoints write fPoints;
  end;

  { TRLImageObject }

  TRLImageObject=class(TRLGraphicObject)
  private
    fData  :AnsiString;
    fParity:boolean;
    //
  public
    constructor Create(aSurface:TRLGraphicSurface); override;
    //
    procedure   SaveToStream(aStream:TStream); override;
    procedure   LoadFromStream(aStream:TStream); override;
    //
    procedure   PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
    procedure   Assign(aObject:TRLGraphicObject); override;
    //
    property    Data  :AnsiString  read fData   write fData;
    property    Parity:boolean read fParity write fParity;
  end;

  { TRLSetClipRectObject }

  TRLSetClipRectObject=class(TRLGraphicObject)
  public
    procedure PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
  end;

  { TRLResetClipRectObject }

  TRLResetClipRectObject=class(TRLGraphicObject)
  public
    procedure PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer); override;
  end;

function  GetPointsBounds(const aPoints:TRLMetaPointArray):TRect;
function  FloatToPtStr(f:double):AnsiString;
function  PtStrToFloat(const s:String; def:Extended=0):Extended;
function  ClipGraphic(aGraphic:TGraphic; var aRect:TRect; const aCenter:boolean):TBitmap;
function  ClipSurface(aSurface:TRLGraphicSurface; var aRect:TRect; const aCenter:boolean):TRLGraphicSurface;

function  MetaPoint(X,Y:integer):TRLMetaPoint;
function  MetaRect(aLeft,aTop,aRight,aBottom:integer):TRLMetaRect;
function  MetaColor(aRed,aGreen,aBlue:byte):TRLMetaColor;

{@function NewGroupId - Cria um identificador para um novo grupo de elementos gr�ficos.
 @links TRLGraphicObject.GroupId, TRLGraphicSurface.GeneratorId, TRLGraphicObject.GeneratorId. :/}
function NewGroupId:integer;

{/@unit}

implementation

uses RLMetaVCL;

{ UTILS }

var
  CurrentGroupId:integer=0;

function NewGroupId:integer;
begin
  Inc(CurrentGroupId);
  Result:=CurrentGroupId;
end;

// retorna dimens�es de uma cole��o de pontos
function GetPointsBounds(const aPoints:TRLMetaPointArray):TRect;
var
  i:integer;
  p:TRLMetaPoint;
begin
  for i:=0 to High(aPoints) do
  begin
    p:=aPoints[i];
    if i=0 then
    begin
      Result.Left  :=p.X;
      Result.Top   :=p.Y;
      Result.Right :=p.X;
      Result.Bottom:=p.Y;
    end
    else
    begin
      Result.Left  :=Min(p.X,Result.Left);
      Result.Top   :=Min(p.Y,Result.Top);
      Result.Right :=Max(p.X,Result.Right);
      Result.Bottom:=Max(p.Y,Result.Bottom);
    end;
  end;
  Dec(Result.Left);
  Dec(Result.Top);
  Inc(Result.Right);
  Inc(Result.Bottom);
end;

// de float para string com ponto como separador decimal
function FloatToPtStr(f:double):AnsiString;
begin
  Str(f:0:4,Result);
end;

// de string com ponto como separador decimal para float 
function PtStrToFloat(const s:String; def:Extended=0):Extended;
var e:integer;
begin
  Val(s, Result, e);
  if e<>0 then
    Result:=def;
end;

// retorna um bitmap a partir de um peda�o recortado do gr�fico aGraphic que caiba em aRect
function ClipGraphic(aGraphic:TGraphic; var aRect:TRect; const aCenter:boolean):TBitmap;
var
  graphicrect:TRect;
begin
  // cria um ret�ngulo com o tamanho natural do gr�fico na posi��o de corte 
  graphicrect:=Rect(aRect.Left,aRect.Top,aRect.Left+aGraphic.Width,aRect.Top+aGraphic.Height);
  // centraliza os dois ret�ngulos
  if aCenter then
    OffsetRect(graphicrect,((aRect.Right-aRect.Left)-(graphicrect.Right-graphicrect.Left)) div 2,
                           ((aRect.Bottom-aRect.Top)-(graphicrect.Bottom-graphicrect.Top)) div 2);
  // faz a interse��o dos dois ret�ngulos em aRect
  if IntersectRect(aRect,aRect,graphicrect) then
  begin
    // projeta um bitmap do tamanho de aRect e de qualidade compat�vel com aGraphic
    Result:=TBitmap.Create;
    Result.Width :=aRect.Right-aRect.Left;
    Result.Height:=aRect.Bottom-aRect.Top;
    Result.PixelFormat:=pf32bit;
    // transfere imagem para o novo bitmap
    Result.Canvas.Draw(graphicrect.Left-aRect.Left,graphicrect.Top-aRect.Top,aGraphic);
  end
  // se n�o houver interse��o...
  else
    Result:=nil;
end;

// retorna um bitmap a partir de um peda�o recortado do gr�fico aGraphic que caiba em aRect
function ClipSurface(aSurface:TRLGraphicSurface; var aRect:TRect; const aCenter:boolean):TRLGraphicSurface;
var
  graphicrect:TRect;
begin
  // cria um ret�ngulo com o tamanho natural do gr�fico na posi��o de corte
  graphicrect:=Rect(aRect.Left,aRect.Top,aRect.Left+aSurface.Width,aRect.Top+aSurface.Height);
  // centraliza os dois ret�ngulos
  if aCenter then
    OffsetRect(graphicrect,((aRect.Right-aRect.Left)-(graphicrect.Right-graphicrect.Left)) div 2,
                           ((aRect.Bottom-aRect.Top)-(graphicrect.Bottom-graphicrect.Top)) div 2);
  // faz a interse��o dos dois ret�ngulos em aRect
  if IntersectRect(aRect,aRect,graphicrect) then
  begin
    // projeta um bitmap do tamanho de aRect e de qualidade compat�vel com aGraphic
    Result:=TRLGraphicSurface.Create;
    Result.Width :=aRect.Right-aRect.Left;
    Result.Height:=aRect.Bottom-aRect.Top;
    // transfere imagem para o novo bitmap
    Result.Draw(graphicrect.Left-aRect.Left,graphicrect.Top-aRect.Top,aSurface);
  end
  // se n�o houver interse��o...
  else
    Result:=nil;
end;

function MetaPoint(X,Y:integer):TRLMetaPoint;
begin
  Result.X:=X;
  Result.Y:=Y;
end;

function MetaRect(aLeft,aTop,aRight,aBottom:integer):TRLMetaRect;
begin
  Result.Left  :=aLeft;
  Result.Top   :=aTop;
  Result.Right :=aRight;
  Result.Bottom:=aBottom;
end;

function MetaColor(aRed,aGreen,aBlue:byte):TRLMetaColor;
begin
  Result.Red  :=aRed;
  Result.Green:=aGreen;
  Result.Blue :=aBlue;
end;

{ Compatibility }

const
  // TGraphicKind
  gkPixel      =0;
  gkLine       =1;
  gkRectangle  =2;
  gkTextOut    =3;
  gkTextRect   =4;
  gkFillRect   =5;
  gkStretchDraw=6;
  gkDraw       =7;
  gkEllipse    =8;
  gkPolygon    =9;
  gkPolyline   =10;
  gkCutBegin   =11;
  gkCutEnd     =12;
  // TImageKind
  ikBitmap  =0;
  ikJPeg    =1;
  ikIcon    =2;
  ikMetafile=3;
type
  TGraphicKind      =byte;
  TImageKind        =byte;
  TTextAlignmentType=byte;
  TPenRecord=record
    Color:TColor;
    Mode :TPenMode;
    Style:TPenStyle;
    Width:integer;
  end;
  TBrushRecord=record
    Color:TColor;
    Style:TBrushStyle;
  end;
  TFontRecord=record
    Color        :TColor;
    Height       :integer;
    Pitch        :TFontPitch;
    PixelsPerInch:integer;
    Size         :integer;
    Style        :TFontStyles;
    Charset      :TFontCharset;
    Angle        :double;
    NameId       :integer;
  end;
  TGraphicFileRecord=record
    X1,Y1,X2,Y2:integer;
    X,Y        :integer;
    Tag        :integer;
    Kind       :TGraphicKind;
    Color      :TColor;
    HasPen     :boolean;
    Pen        :TPenRecord;
    HasBrush   :boolean;
    Brush      :TBrushRecord;
    HasFont    :boolean;
    Font       :TFontRecord;
    Text       :integer;
    Alignment  :TTextAlignmentType;
    AutoSize   :boolean;
  end;
  
  TPointArray=array of TPoint;

procedure UpgradePage(aStorage:TRLGraphicStorage; aInput,aOutput:TStream);
var
  surface:TRLGraphicSurface;
  texts  :TStringList;
  count  :integer;
  len    :integer;
  i      :integer;
  s      :String;
  rec    :TGraphicFileRecord;
  pgraph :TGraphic;
  cutlist:array of TRect;
  cutrect:TRect;
  cutlen :integer;
  cutsize:integer;
function StrToGraphic(const aStr:AnsiString; aImageKind:TImageKind):TGraphic;
var
  s:TStringStream;
begin
  s:=TStringStream.Create(aStr);
  try
    case aImageKind of
      ikBitmap: Result:=TBitmap.Create;
      ikIcon  : Result:=TIcon.Create;
    else
      Result:=nil;
    end;
    if Assigned(Result) then
    begin
      s.Position:=0;
      Result.LoadFromStream(s);
    end;
  finally
    s.free;
  end;
end;
function StrToPoints(const aStr:AnsiString):TPointArray;
var
  q,i:integer;
begin
  q:=Length(aStr) div SizeOf(TPoint);
  SetLength(Result,q);
  for i:=0 to q-1 do
    Move(aStr[i*SizeOf(TPoint)+1],Result[i],SizeOf(TPoint));
end;
begin
  cutlen :=0;
  cutsize:=0;
  //
  surface:=TRLGraphicSurface.Create;
  try
    aInput.Read(surface.fWidth ,SizeOf(surface.fWidth));
    aInput.Read(surface.fHeight,SizeOf(surface.fHeight));
    surface.Orientation:=aStorage.Orientation;
    surface.PaperHeight:=aStorage.PaperHeight;
    surface.PaperWidth :=aStorage.PaperWidth;
    //
    cutrect:=Rect(0,0,surface.fWidth,surface.fHeight);
    // strings
    texts:=TStringList.Create;
    try
      aInput.Read(count,SizeOf(count));
      for i:=0 to count-1 do
      begin
        aInput.Read(len,SizeOf(len));
        SetLength(s,len);
        aInput.Read(s[1],len);
        texts.Add(s);
      end;
      // objects
      aInput.Read(count,SizeOf(count));
      for i:=1 to count do
      begin
        aInput.Read(rec,SizeOf(rec));

        case rec.Kind of
          gkPixel      : with TRLPixelObject.Create(surface) do
                         begin
                           BoundsRect:= ToMetaRect(Rect(rec.X1,rec.Y1,rec.X2,rec.Y2));
                           Color     := ToMetaColor(rec.Color);
                         end;
          gkLine       : with TRLLineObject.Create(surface) do
                         begin
                           FromPoint :=ToMetaPoint(Point(rec.X1,rec.Y1));
                           ToPoint   :=ToMetaPoint(Point(rec.X2,rec.Y2));
                           BoundsRect:=ToMetaRect(Rect(Min(FromPoint.X,ToPoint.X),
                                                     Min(FromPoint.Y,ToPoint.Y),
                                                     Max(FromPoint.X,ToPoint.X),
                                                     Max(FromPoint.Y,ToPoint.Y)));
                           Pen.Color :=ToMetaColor(rec.Pen.Color);
                           Pen.Mode  :=ToMetaPenMode(rec.Pen.Mode);
                           Pen.Style :=ToMetaPenStyle(rec.Pen.Style);
                           Pen.Width :=rec.Pen.Width;
                         end;
          gkRectangle  : with TRLRectangleObject.Create(surface) do
                         begin
                           BoundsRect :=ToMetaRect(Rect(rec.X1,rec.Y1,rec.X2,rec.Y2));
                           Pen.Color  :=ToMetaColor(rec.Pen.Color);
                           Pen.Mode   :=ToMetaPenMode(rec.Pen.Mode);
                           Pen.Style  :=ToMetaPenStyle(rec.Pen.Style);
                           Pen.Width  :=rec.Pen.Width;
                           Brush.Color:=ToMetaColor(rec.Brush.Color);
                           Brush.Style:=ToMetaBrushStyle(rec.Brush.Style);
                         end;
          gkTextOut,
          gkTextRect   : with TRLTextObject.Create(surface) do
                         begin
                           BoundsRect        :=ToMetaRect(Rect(rec.X1,rec.Y1,rec.X2,rec.Y2));
                           Text              :=AnsiString(texts[rec.Text]);//bds2010
                           Origin            :=ToMetaPoint(Point(rec.X,rec.Y));
                           Alignment         :=rec.Alignment+1;
                           Layout            :=MetaTextLayoutTop;
                           if rec.AutoSize or (rec.Kind=gkTextOut) then
                             TextFlags:=TextFlags or MetaTextFlagAutoSize;
                           Brush.Color       :=ToMetaColor(rec.Brush.Color);
                           Brush.Style       :=ToMetaBrushStyle(rec.Brush.Style);
                           Font.PixelsPerInch:=ScreenPPI; //rec.Font.PixelsPerInch;
                           Font.Charset      :=ToMetaFontCharset(rec.Font.Charset);
                           Font.Color        :=ToMetaColor(rec.Font.Color);
                           Font.Height       :=rec.Font.Height;
                           Font.Name         :=texts[rec.Font.NameId];
                           Font.Pitch        :=ToMetaFontPitch(rec.Font.Pitch);
                           Font.Size         :=-Round(Font.Height*72/Font.PixelsPerInch);
                           Font.Style        :=ToMetaFontStyles(rec.Font.Style);
                         end;
          gkFillRect   : with TRLFillRectObject.Create(surface) do
                         begin
                           BoundsRect :=ToMetaRect(Rect(rec.X1,rec.Y1,rec.X2,rec.Y2));
                           Brush.Color:=ToMetaColor(rec.Brush.Color);
                           Brush.Style:=ToMetaBrushStyle(rec.Brush.Style);
                         end;
          gkStretchDraw: with TRLImageObject.Create(surface) do
                         begin
                           BoundsRect:=ToMetaRect(Rect(rec.X1,rec.Y1,rec.X2,rec.Y2));
                           Parity    :=false;
                           pgraph:=StrToGraphic(AnsiString(texts[rec.Text]),rec.Tag);
                           try
                             Data:=AnsiString(ToMetaGraphic(pgraph));//bds2010
                           finally
                             pgraph.free;
                           end;
                         end;
          gkDraw       : with TRLImageObject.Create(surface) do
                         begin
                           BoundsRect:=ToMetaRect(Rect(rec.X1,rec.Y1,rec.X2,rec.Y2));
                           Parity    :=false;
                           pgraph:=StrToGraphic(AnsiString(texts[rec.Text]),rec.Tag);
                           try
                             Data:=AnsiString(ToMetaGraphic(pgraph));//bds2010
                           finally
                             pgraph.free;
                           end;
                         end;
          gkEllipse    : with TRLEllipseObject.Create(surface) do
                         begin
                           BoundsRect :=ToMetaRect(Rect(rec.X1,rec.Y1,rec.X2,rec.Y2));
                           Pen.Color  :=ToMetaColor(rec.Pen.Color);
                           Pen.Mode   :=ToMetaPenMode(rec.Pen.Mode);
                           Pen.Style  :=ToMetaPenStyle(rec.Pen.Style);
                           Pen.Width  :=rec.Pen.Width;
                           Brush.Color:=ToMetaColor(rec.Brush.Color);
                           Brush.Style:=ToMetaBrushStyle(rec.Brush.Style);
                         end;
          gkPolygon    : with TRLPolygonObject.Create(surface) do
                         begin
                           Points     :=ToMetaPointArray(StrToPoints(AnsiString(texts[rec.Text])));//bds2010
                           BoundsRect :=ToMetaRect(Rect(rec.X1,rec.Y1,rec.X2,rec.Y2));
                           Pen.Color  :=ToMetaColor(rec.Pen.Color);
                           Pen.Mode   :=ToMetaPenMode(rec.Pen.Mode);
                           Pen.Style  :=ToMetaPenStyle(rec.Pen.Style);
                           Pen.Width  :=rec.Pen.Width;
                           Brush.Color:=ToMetaColor(rec.Brush.Color);
                           Brush.Style:=ToMetaBrushStyle(rec.Brush.Style);
                         end;
          gkPolyline   : with TRLPolylineObject.Create(surface) do
                         begin
                           Points      :=ToMetaPointArray(StrToPoints(AnsiString(texts[rec.Text])));
                           BoundsRect  :=ToMetaRect(Rect(rec.X1,rec.Y1,rec.X2,rec.Y2));
                           Pen.Color   :=ToMetaColor(rec.Pen.Color);
                           Pen.Mode    :=ToMetaPenMode(rec.Pen.Mode);
                           Pen.Style   :=ToMetaPenStyle(rec.Pen.Style);
                           Pen.Width   :=rec.Pen.Width;
                         end;
          gkCutBegin   : with TRLSetClipRectObject.Create(surface) do
                         begin
                           Inc(cutlen);
                           if cutlen>cutsize then
                           begin
                             Inc(cutsize,1024);
                             SetLength(cutlist,cutsize);
                           end;
                           cutlist[cutlen-1]:=cutrect;
                           cutrect          :=Rect(rec.X1,rec.Y1,rec.X2,rec.Y2);
                           BoundsRect       :=ToMetaRect(cutrect);
                         end;
          gkCutEnd     : with TRLResetClipRectObject.Create(surface) do
                         begin
                           cutrect:=cutlist[cutlen-1];
                           Dec(cutlen);
                           BoundsRect:=ToMetaRect(cutrect);
                         end;
        end;
      end;
    finally
      texts.free;
    end;
    //
    surface.SaveToStream(aOutput);
  finally
    surface.free;
  end;
end;

procedure DowngradePage(aInput,aOutput:TStream);
var
  surface:TRLGraphicSurface;
  pen    :TRLMetaPen;
  brush  :TRLMetaBrush;
  font   :^TRLMetaFont;
  rec    :^TGraphicFileRecord;
  textid :integer;
  fontid :integer;
  obj    :TRLGraphicObject;
  texts  :TStringList;
  objcs  :TList;
  count  :integer;
  len    :integer;
  s      :AnsiString;
  i      :integer;
begin
  surface:=TRLGraphicSurface.Create;
  try
    surface.LoadFromStream(aInput);
    //
    texts:=TStringList.Create;
    objcs:=TList.Create;
    try
      for i:=0 to surface.ObjectCount-1 do
      begin
        obj:=surface.Objects[i];
        textid:=-1;
        fontid:=-1;

        new(rec);

        if obj is TRLTextObject then
        begin
          s:=TRLTextObject(obj).Text;
          textid:=texts.Add(String(s));//bds2010
          s:=AnsiString(TRLTextObject(obj).Font.GetName);
          fontid:=texts.indexof(String(s));//bds2010
          if fontid=-1 then
            fontid:=texts.Add(String(s));//bds2010
        end
        else if obj is TRLImageObject then
        begin
          s:=TRLImageObject(obj).Data;
          delete(s,1,3); // retira prefixo
          textid:=texts.Add(String(s));//bds2010
        end;

        if obj is TRLPixelObject then
          rec^.Kind:=gkPixel
        else if obj is TRLLineObject then
          rec^.Kind:=gkLine
        else if obj is TRLRectangleObject then
          rec^.Kind:=gkRectangle
        else if obj is TRLTextObject then
          if (TRLTextObject(obj).TextFlags and MetaTextFlagAutoSize)=MetaTextFlagAutoSize then
            rec^.Kind:=gkTextOut
          else
            rec^.Kind:=gkTextRect
        else if obj is TRLFillRectObject then
          rec^.Kind:=gkFillRect
        else if obj is TRLImageObject then
          rec^.Kind:=gkStretchDraw
        else if obj is TRLEllipseObject then
          rec^.Kind:=gkEllipse
        else if obj is TRLPolygonObject then
          rec^.Kind:=gkPolygon
        else if obj is TRLPolylineObject then
          rec^.Kind:=gkPolyline
        else if obj is TRLSetClipRectObject then
          rec^.Kind:=gkCutBegin
        else if obj is TRLResetClipRectObject then
          rec^.Kind:=gkCutEnd;

        if obj is TRLLineObject then
        begin
          rec^.X1:=TRLLineObject(obj).FromPoint.X;
          rec^.Y1:=TRLLineObject(obj).FromPoint.Y;
          rec^.X2:=TRLLineObject(obj).ToPoint.X;
          rec^.Y2:=TRLLineObject(obj).ToPoint.Y;
        end
        else
        begin
          rec^.X1:=TRLLineObject(obj).BoundsRect.Left;
          rec^.Y1:=TRLLineObject(obj).BoundsRect.Top;
          rec^.X2:=TRLLineObject(obj).BoundsRect.Right;
          rec^.Y2:=TRLLineObject(obj).BoundsRect.Bottom;
        end;
        if obj is TRLTextObject then
        begin
          rec^.X:=TRLTextObject(obj).Origin.X;
          rec^.Y:=TRLTextObject(obj).Origin.Y;
        end
        else
        begin
          rec^.X:=0;
          rec^.Y:=0;
        end;
        if obj is TRLImageObject then
        begin
          s:=TRLImageObject(obj).Data;
          if copy(s,1,3)='BMP' then
            rec^.Tag:=ord(ikBitmap)
          else if copy(s,1,3)='ICO' then
            rec^.Tag:=ord(ikIcon);
        end;
        rec^.Color:=0; // not used
        if obj is TRLTextObject then
        begin
          rec^.Alignment:=TRLTextObject(obj).Alignment-1;
          rec^.AutoSize :=((TRLTextObject(obj).TextFlags and MetaTextFlagAutoSize)=MetaTextFlagAutoSize);
        end;

        if obj is TRLLineObject then
          pen:=TRLLineObject(obj).Pen
        else if obj is TRLRectangleObject then
          pen:=TRLRectangleObject(obj).Pen
        else if obj is TRLEllipseObject then
          pen:=TRLEllipseObject(obj).Pen
        else if obj is TRLPolygonObject then
          pen:=TRLPolygonObject(obj).Pen
        else if obj is TRLPolylineObject then
          pen:=TRLPolylineObject(obj).Pen
        else
          pen:=nil;

        rec^.HasPen:=(pen<>nil);
        if rec^.HasPen then
        begin
          rec^.Pen.Color:=FromMetaColor(pen.Color);
          rec^.Pen.Mode :=FromMetaPenMode(pen.Mode);
          rec^.Pen.Style:=FromMetaPenStyle(pen.Style);
          rec^.Pen.Width:=pen.Width;
        end;

        if obj is TRLRectangleObject then
          brush:=TRLRectangleObject(obj).Brush
        else if obj is TRLTextObject then
          brush:=TRLTextObject(obj).Brush
        else if obj is TRLFillRectObject then
          brush:=TRLFillRectObject(obj).Brush
        else if obj is TRLEllipseObject then
          brush:=TRLEllipseObject(obj).Brush
        else if obj is TRLPolygonObject then
          brush:=TRLPolygonObject(obj).Brush
        else
          brush:=nil;

        rec^.HasBrush:=(brush<>nil);
        if rec^.HasBrush then
        begin
          rec^.Brush.Color:=FromMetaColor(brush.Color);
          rec^.Brush.Style:=FromMetaBrushStyle(brush.Style);
        end;

        if obj is TRLTextObject then
          font:=@TRLTextObject(obj).Font
        else
          font:=nil;
        rec^.HasFont:=(font<>nil);
        if rec^.HasFont then
        begin
          rec^.Font.NameId :=fontid;
          rec^.Font.Charset:=FromMetaFontCharset(font^.Charset);
          rec^.Font.Pitch  :=FromMetaFontPitch(font^.Pitch);
          rec^.Font.Height :=font^.Height;
          rec^.Font.Style  :=FromMetaFontStyles(font^.Style);
          rec^.Font.Color  :=FromMetaColor(font^.Color);
        end;

        rec^.Text:=textid;

        objcs.Add(rec);
      end;
      //
      aOutput.Write(surface.fWidth ,SizeOf(surface.fWidth));
      aOutput.Write(surface.fHeight,SizeOf(surface.fHeight));
      count:=texts.Count;
      aOutput.Write(count,SizeOf(count));
      for i:=0 to count-1 do
      begin
        s:=AnsiString(texts[i]);
        len:=Length(s);
        aOutput.Write(len,SizeOf(len));
        aOutput.Write(s[1],len);
      end;
      count:=objcs.Count;
      aOutput.Write(count,SizeOf(count));
      for i:=0 to count-1 do
      begin
        rec:=objcs[i];
        aOutput.Write(rec^,SizeOf(TGraphicFileRecord));
        dispose(rec);
      end;
    finally
      texts.free;
      objcs.free;
    end;
  finally
    surface.free;
  end;
end;

{ TRLGraphicStorage }

constructor TRLGraphicStorage.Create(aOwner:TComponent); 
begin
  fPageCache     :=nil;
  fPageAllocation:=nil;
  fTempStream    :=nil;
  fTempFileName  :='';
  fFileVersion   :=3;
  fMacros        :=nil;
  fReferenceList :=nil;
  //
  fPageCache     :=TObjectList.Create;
  fPageAllocation:=TList.Create;
  fMacros        :=TStringList.Create;
  fReferenceList :=TList.Create;
  //
  inherited;
end;

destructor TRLGraphicStorage.Destroy;
begin
  inherited;
  //
  if Assigned(fReferenceList) then
    fReferenceList.free;
  if Assigned(fPageCache) then
    fPageCache.free;
  if Assigned(fPageAllocation) then
    fPageAllocation.free;
  if Assigned(fMacros) then
    fMacros.free;
  if Assigned(fTempStream) then
  begin
    fTempStream.free;
    SysUtils.DeleteFile(fTempFileName);
    UnregisterTempFile(fTempFileName);
  end;
end;

procedure TRLGraphicStorage.Notification(aComponent:TComponent; Operation:TOperation);
begin
  inherited;
  //
  if Operation=opRemove then
    Unlink(aComponent);
end;

procedure TRLGraphicStorage.Link(aComponent:TComponent);
begin
  if (aComponent<>Owner) and (fReferenceList.IndexOf(aComponent)=-1) then
  begin
    fReferenceList.Add(aComponent);
    aComponent.FreeNotification(Self);
  end;
end;

procedure TRLGraphicStorage.Unlink(aComponent:TComponent=nil);
var
  i:integer;
begin
  if csDestroying in ComponentState then
    Exit;
  i:=fReferenceList.IndexOf(aComponent);
  if i<>-1 then
  begin
    fReferenceList.Delete(i);
    if not Assigned(Self.Owner) and (fReferenceList.Count=0) then
      Self.Free;
  end;
end;

procedure TRLGraphicStorage.Update(aSurface:TRLGraphicSurface);
var
  size,datapos,beginpos,endpos:integer;
begin
  TempStreamNeeded;
  fTempStream.Position:=fTempStream.Size;
  // guarda a posi��o de grava��o e reserva espa�o para o tamanho
  beginpos:=fTempStream.Position;
  size    :=0;
  fTempStream.Write(size,SizeOf(size));
  datapos :=fTempStream.Position;
  // atualiza a lista de p�ginas atribuindo o novo offset
  if aSurface.fPageIndex=-1 then
    aSurface.fPageIndex:=fPageAllocation.Add(Pointer(beginpos))
  else
    fPageAllocation[aSurface.fPageIndex]:=Pointer(beginpos);
  // salva a p�gina em disco
  aSurface.SaveToStream(fTempStream);
  // atualiza o tamanho no in�cio da grava��o e retorna o cursor para o fim do arquivo
  endpos:=fTempStream.Position;
  size  :=endpos-datapos;
  fTempStream.Position:=beginpos;
  fTempStream.Write(size,SizeOf(size));
  fTempStream.Position:=endpos;
  aSurface.Modified:=False;
end;

procedure TRLGraphicStorage.RetrievePage(aSurface:TRLGraphicSurface);
var
  size:integer;
begin
  fTempStream.Position:=Integer(fPageAllocation[aSurface.fPageIndex]);
  fTempStream.Read(size,SizeOf(size));
  aSurface.LoadFromStream(fTempStream);
end;

procedure TRLGraphicStorage.Add(aSurface:TRLGraphicSurface);
begin
  aSurface.SetStorage(Self);
  Update(aSurface);
  AddToCache(aSurface);
end;

function TRLGraphicStorage.New(PaperWidth, PaperHeight: integer):TRLGraphicSurface;
begin
  Result:=TRLGraphicSurface.Create;
  Result.Width      :=IfThen(PaperWidth<0,-1,Round(ScreenPPI*PaperWidth/InchAsMM));
  Result.Height     :=IfThen(PaperHeight<0,-1,Round(ScreenPPI*PaperHeight/InchAsMM));
  Result.Orientation:=MetaOrientationPortrait;
  Result.PaperWidth :=IfThen(PaperWidth<0,-1,PaperWidth);
  Result.PaperHeight:=IfThen(PaperHeight<0,-1,PaperHeight);
  Result.Open;
  Result.SetStorage(Self);
  AddToCache(Result);
end;

procedure TRLGraphicStorage.Clear;
begin
  if Assigned(fTempStream) then
    fTempStream.Size:=0;
  fPageAllocation.Clear;
  fPageCache.Clear;
  fMacros.Clear;
end;

procedure TRLGraphicStorage.AddToCache(aSurface:TRLGraphicSurface);
var
  s:TRLGraphicSurface;
begin
  // limite de dez p�ginas em cach�
  if fPageCache.Count>=MAXPAGECACHE then
  begin
    s:=TRLGraphicSurface(fPageCache[0]);
    if s.Modified then
      Update(s);
    fPageCache.Remove(s);
  end;
  fPageCache.Add(aSurface);
end;

function TRLGraphicStorage.GetFromCache(aPageIndex:integer):TRLGraphicSurface;
var
  i:integer;
begin
  Result:=nil;
  if (aPageIndex>=0) and Assigned(fPageCache) then
  begin
    i:=0;
    while (i<fPageCache.Count) and (TRLGraphicSurface(fPageCache[i]).PageIndex<>aPageIndex) do
      Inc(i);
    if i<fPageCache.Count then
      Result:=TRLGraphicSurface(fPageCache[i]);
  end;
end;

procedure TRLGraphicStorage.FlushCache;
var
  s:TRLGraphicSurface;
  i:integer;
begin
  for i:=0 to fPageCache.Count-1 do
  begin
    s:=TRLGraphicSurface(fPageCache[i]);
    if s.Modified then
      Update(s);
  end;
end;

function TRLGraphicStorage.LoadPageFromDisk(aPageIndex:integer):TRLGraphicSurface;
begin
  if (aPageIndex>=0) and (aPageIndex<fPageAllocation.Count) then
  begin
    Result:=TRLGraphicSurface.Create;
    try
      Result.SetStorage(Self); 
      Result.fPageIndex:=aPageIndex;
      RetrievePage(Result);
    except
      Result.free;
      Result:=nil;
    end;
  end
  else
    Result:=nil;
end;

function TRLGraphicStorage.GetPages(aPageIndex:integer):TRLGraphicSurface;
begin
  Result:=GetFromCache(aPageIndex);
  if Result=nil then
  begin
    Result:=LoadPageFromDisk(aPageIndex);
    if Result<>nil then
      AddToCache(Result);
  end;
end;

function TRLGraphicStorage.GetPageCount: integer;
begin
  Result:=fPageAllocation.Count;
end;

procedure TRLGraphicStorage.TempStreamNeeded;
begin
  if not Assigned(fTempStream) then
  begin
    fTempFileName:=GetTempFileName;
    RegisterTempFile(fTempFileName);
    fTempStream  :=TFileStream.Create(fTempFileName,fmCreate);
  end;
end;

procedure TRLGraphicStorage.SaveToFile(const aFileName: String);
var
  s:TFileStream;
begin
  s:=TFileStream.Create(aFileName,fmCreate);
  try
    SaveToStream(s);
  finally
    s.free;
  end;
end;

procedure TRLGraphicStorage.LoadFromFile(const aFileName: String);
var
  s:TFileStream;
begin
  s:=TFileStream.Create(aFileName,fmOpenRead+fmShareDenyWrite);
  try
    LoadFromStream(s);
  finally
    s.free;
  end;
end;

const
  MaxFileHeader     =20;
  FileHeaderVersion1='Fortes Metafile'#26;
  FileHeaderVersion2='RPF2'#26;
  FileHeaderVersion3='RLGraphicStorage3'#26;

procedure TRLGraphicStorage.SaveToStream(aStream: TStream);
  function SaveHeaderToStream(aStream: TStream):integer;
  var
    data:AnsiString;
  begin
    case fFileVersion of
      1: data:=FileHeaderVersion1;
      2: data:=FileHeaderVersion2;
      3: data:=FileHeaderVersion3;
    else
      raise Exception.Create('Incorrect file version "'+IntToStr(fFileVersion)+'"!');
    end;
    Result:=aStream.Position;
    aStream.Write(data[1],Length(data));
  end;
  procedure SaveMacrosToStream(aStream: TStream);
  var
    count,len,i,p:integer;
    ln,name,value:AnsiString;
  begin
    // grava a quantidade de macros
    count:=fMacros.Count;
    aStream.Write(count,SizeOf(count));
    // grava s�mbolos
    for i:=0 to count-1 do
    begin
      ln:=AnsiString(fMacros[i]); //bds2010
      // downgrade
      p:=Pos('=',String(ln));
      if p<>0 then
      begin
        name :=AnsiString(Trim(String(Copy(ln,1,p-1))));//bds2010
        value:=AnsiSTring(Trim(String(Copy(ln,p+1,Length(ln)))));//bds2010
        if (fFileVersion<3) and AnsiSameText(String(name),'Orientation') then//bds2010
          ln:=name+'='+AnsiString(IntToStr(StrToIntDef(String(value),1)-1));//bds2010
      end;
      // grava length + nome
      len:=Length(ln);
      aStream.Write(len,SizeOf(len));
      aStream.Write(ln[1],len);
    end;
  end;
  function SavePageToStream(aStream:TStream; aPageIndex:integer):integer;
  var
    size:integer;
  begin
    // l� o tamanho da p�gina armazenada
    fTempStream.Position:=Integer(fPageAllocation[aPageIndex]);
    fTempStream.Read(size,SizeOf(size));
    // guarda posi��o inicial de grava��o da nova stream
    Result:=aStream.Position;
    // vers�es >2 gravam o tamanho da p�gina
    if fFileVersion>2 then
      aStream.Write(size,SizeOf(size));
    // grava p�gina no novo stream
    if fFileVersion>2 then
      aStream.CopyFrom(fTempStream,size)
    else
      DowngradePage(fTempStream,aStream);  
  end;
  procedure SavePagesToStream(aStream: TStream);
  var
    pagetbl,count,savedpos,page0,i:integer;
    offsets:array of integer;
  begin
    // grava a quantidade de p�ginas
    count:=fPageAllocation.Count;
    aStream.Write(count,SizeOf(count));
    // guarda posi��o inicial de grava��o da tabela de p�ginas
    pagetbl:=aStream.Position;
    // reserva espa�o para os offsets
    SetLength(offsets,count);
    for i:=0 to count-1 do
      aStream.Write(offsets[i],SizeOf(offsets[i]));
    // grava p�ginas e memoriza os offsets
    page0:=aStream.Position;
    for i:=0 to fPageAllocation.Count-1 do
      offsets[i]:=SavePageToStream(aStream,i);
    // guarda posi��o atual, grava offsets e restaura posi��o
    savedpos:=aStream.Position;
    aStream.Position:=pagetbl;
    for i:=0 to count-1 do
    begin
      // nas vers�es <=2 o offsets da primeira p�gina era 0 
      if fFileVersion<=2 then
        Dec(offsets[i],page0);
      aStream.Write(offsets[i],SizeOf(offsets[i]));
    end;  
    aStream.Position:=savedpos;
  end;
begin
  FlushCache;
  SaveHeaderToStream(aStream);
  if fFileVersion>=2 then
    SaveMacrosToStream(aStream);
  SavePagesToStream(aStream);
end;

procedure TRLGraphicStorage.LoadFromStream(aStream:TStream);
  procedure LoadHeaderFromStream(aStream:TStream);
  var
    data: AnsiString;
    ch  : AnsiChar;
    i   :integer;
  begin
    SetLength(data,MaxFileHeader);
    i:=0;
    while (i<MaxFileHeader) and (aStream.Read(ch,1)=1) do
    begin
      Inc(i);
      data[i]:=ch;
      if ch=#26 then
        break;
    end;
    SetLength(data,i);
    if data=FileHeaderVersion1 then
      fFileVersion:=1
    else if data=FileHeaderVersion2 then
      fFileVersion:=2
    else if data=FileHeaderVersion3 then
      fFileVersion:=3
    else
      raise Exception.CreateFmt('Corrupt file header "%s"!', [data]);
  end;
  procedure LoadMacrosFromStream(aStream:TStream);
  var
    count,len,i,p:integer;
    ln,name,value:AnsiString;
  begin
    aStream.Read(count,SizeOf(count));
    // grava s�mbolos e seus valores
    for i:=0 to count-1 do
    begin
      // l� length + nome
      aStream.Read(len,SizeOf(len));
      SetLength(ln,len);
      aStream.Read(ln[1],len);
      // upgrade
      p:=Pos('=',String(ln));
      if p<>0 then
      begin
        name :=AnsiString(Trim(String(Copy(ln,1,p-1))));//bds2010
        value:=AnsiString(Trim(String(Copy(ln,p+1,Length(String(ln))))));//bds2010
        if (fFileVersion<3) and AnsiSameText(String(name),'Orientation') then
          ln:=name+'='+AnsiString(IntToStr(StrToIntDef(String(value),0)+1));//bds2010
      end;
      //
      fMacros.Add(String(ln));//bds2010
    end;
  end;
  procedure LoadPageTableFromStream(aStream:TStream);
  var
    count,offset,page0,i:integer;
  begin
    aStream.Read(count,SizeOf(count));
    // l� offsets
    for i:=0 to count-1 do
    begin
      aStream.Read(offset,SizeOf(offset));
      fPageAllocation.Add(Pointer(offset));
    end;
    // nas vers�es <=2 o offsets da primeira p�gina era 0
    if fFileVersion<=2 then
    begin
      page0:=aStream.Position;
      for i:=0 to count-1 do
        fPageAllocation[i]:=Pointer(Integer(fPageAllocation[i])+page0);
    end;
  end;
  procedure LoadPageFromStream(aStream:TStream; aPageIndex:integer);
  var
    size,sizeat,beginat,endat:integer;
  begin
    // l� o tamanho da p�gina armazenada
    aStream.Position:=Integer(fPageAllocation[aPageIndex]);
    // vers�es >2 indicam o tamanho da p�gina
    if fFileVersion>2 then
      aStream.Read(size,SizeOf(size))
    else
      size:=0;
    // atualiza tabela de p�ginas
    fPageAllocation[aPageIndex]:=Pointer(fTempStream.Position);
    // grava o tamanho
    sizeat:=fTempStream.Position;
    fTempStream.Write(size,SizeOf(size));
    // grava p�gina no stream de trabalho
    if fFileVersion>2 then
      fTempStream.CopyFrom(aStream,size)
    else
    begin
      beginat:=fTempStream.Position;
      UpgradePage(Self,aStream,fTempStream);
      endat  :=fTempStream.Position;
      fTempStream.Position:=sizeat;
      size:=endat-beginat;
      fTempStream.Write(size,SizeOf(size));
      fTempStream.Position:=endat;
    end;
  end;
  procedure LoadPagesFromStream(aStream: TStream);
  var
    i:integer;
  begin
    for i:=0 to fPageAllocation.Count-1 do
      LoadPageFromStream(aStream,i);
  end;
begin
  Clear;
  LoadHeaderFromStream(aStream);
  if fFileVersion>=2 then
    LoadMacrosFromStream(aStream);
  LoadPageTableFromStream(aStream);
  TempStreamNeeded;
  LoadPagesFromStream(aStream);
end;

procedure TRLGraphicStorage.SetFileVersion(aVersion:integer);
begin
  if (aVersion<1) or (aVersion>3) then
    raise Exception.Create('Invalid file version!');
  fFileVersion:=aVersion;  
end;

function TRLGraphicStorage.GetFirstPageNumber: integer;
begin
  Result:=StrToIntDef(fMacros.Values['FirstPageNumber'],0);
end;

procedure TRLGraphicStorage.SetFirstPageNumber(const Value: integer);
begin
  fMacros.Values['FirstPageNumber']:=IntToStr(Value);
end;

function TRLGraphicStorage.GetLastPageNumber: integer;
begin
  Result:=StrToIntDef(fMacros.Values['LastPageNumber'],0);
end;

procedure TRLGraphicStorage.SetLastPageNumber(const Value: integer);
begin
  fMacros.Values['LastPageNumber']:=IntToStr(Value);
end;

function TRLGraphicStorage.GetOrientation: TRLMetaOrientation;
begin
  Result:=StrToIntDef(fMacros.Values['Orientation'],MetaOrientationPortrait);
end;

procedure TRLGraphicStorage.SetOrientation(const Value: TRLMetaOrientation);
begin
  fMacros.Values['Orientation']:=IntToStr(Value);
end;

function TRLGraphicStorage.GetPaperHeight: double;
begin
  Result:=PtStrToFloat(fMacros.Values['PaperHeight'],0);
  if Result<0 then
    Result:=-1;
end;

procedure TRLGraphicStorage.SetPaperHeight(const Value: double);
begin
  fMacros.Values['PaperHeight']:=String(FloatToPtStr(IfThen(Value<0,-1,Value)));//bds2010
end;

function TRLGraphicStorage.GetPaperWidth: double;
begin
  Result:=PtStrToFloat(fMacros.Values['PaperWidth'],0);
  if Result<0 then
    Result:=-1;
end;

procedure TRLGraphicStorage.SetPaperWidth(const Value: double);
begin
  fMacros.Values['PaperWidth']:=String(FloatToPtStr(IfThen(Value<0,-1,Value)));//bds2010
end;

function TRLGraphicStorage.GetTitle: String;
begin
  Result:=fMacros.Values['Title'];
end;

procedure TRLGraphicStorage.SetTitle(const Value: String);
begin
  fMacros.Values['Title']:=Value;
end;

function TRLGraphicStorage.GetHeight: integer;
begin
  if PaperHeight<0 then
    Result:=StrToIntDef(fMacros.Values['Height'],100)
  else
    Result:=Round(PaperHeight*MMAsPixels);
end;

function TRLGraphicStorage.GetWidth: integer;
begin
  if PaperWidth<0 then
    Result:=StrToIntDef(fMacros.Values['Width'],100)
  else
    Result:=Round(PaperWidth*MMAsPixels);
end;

function TRLGraphicStorage.GetOrientedPaperHeight: double;
begin
  if Orientation=MetaOrientationPortrait then
    Result:=PaperHeight
  else
    Result:=PaperWidth;
end;

function TRLGraphicStorage.GetOrientedPaperWidth: double;
begin
  if Orientation=MetaOrientationPortrait then
    Result:=PaperWidth
  else
    Result:=PaperHeight;
end;

function TRLGraphicStorage.GetOrientedHeight: integer;
begin
  if OrientedPaperHeight<0 then
    Result:=-1
  else
    Result:=Round(OrientedPaperHeight*MMAsPixels);
end;

function TRLGraphicStorage.GetOrientedWidth: integer;
begin
  if OrientedPaperWidth<0 then
    Result:=-1
  else
    Result:=Round(OrientedPaperWidth*MMAsPixels);
end;

procedure TRLGraphicStorage.SetHeight(const Value: integer);
begin
  fMacros.Values['Height']:=IntToStr(Value);
end;

procedure TRLGraphicStorage.SetWidth(const Value: integer);
begin
  fMacros.Values['Width']:=IntToStr(Value);
end;

{ TRLGraphicSurface }

constructor TRLGraphicSurface.Create;
begin
  fStorage    :=nil;
  fPageIndex  :=-1;
  fObjects    :=nil;
  fPenPos     :=Point(0,0);
  fWidth      :=0;
  fHeight     :=0;
  fBrush      :=nil;
  fFont       :=nil;
  fPen        :=nil;
  fMargins    :=Rect(0,0,0,0);
  fOpened     :=false;
  fModified   :=false;
  fBitmapAux  :=nil;
  fFonts      :=nil;
  fClipStack  :=nil;
  fGeneratorId:=0;
  fMacros     :=nil;
  //
  fBrush:=TBrush.Create;
  fBrush.Color:=clWhite;
  fPen:=TPen.Create;
  fPen.Color:=clBlack;
  fFont:=TFont.Create;
  fFont.Color:=clBlack;
  //
  fObjects  :=TObjectList.Create;
  fFonts    :=TStringList.Create;
  fClipStack:=TList.Create;
  fMacros   :=TStringList.Create;
  //
  inherited Create;
end;

destructor TRLGraphicSurface.Destroy;
begin
  inherited;
  //
  SetStorage(nil);
  if Assigned(fObjects) then
    fObjects.free;
  if Assigned(fBrush) then
    fBrush.free;
  if Assigned(fPen) then
    fPen.free;
  if Assigned(fFont) then
    fFont.free;
  if Assigned(fBitmapAux) then
    fBitmapAux.free;
  if Assigned(fFonts) then
    fFonts.free;
  if Assigned(fClipStack) then
    fClipStack.free;
  if Assigned(fMacros) then
    fMacros.free;
end;

procedure TRLGraphicSurface.SaveToFile(const aFileName:String);
var
  s:TFileStream;
begin
  s:=TFileStream.Create(aFileName,fmCreate);
  try
    SaveToStream(s);
  finally
    s.free;
  end;
end;

procedure TRLGraphicSurface.LoadFromFile(const aFileName:String);
var
  s:TFileStream;
begin
  s:=TFileStream.Create(aFileName,fmOpenRead+fmShareDenyWrite);
  try
    LoadFromStream(s);
  finally
    s.free;
  end;
end;

type
  TGraphicObjectKind=byte; 

const
  ObjectKindPixel        =1;
  ObjectKindLine         =2;
  ObjectKindRectangle    =3;
  ObjectKindText         =4;
  ObjectKindFillRect     =5;
  ObjectKindEllipse      =6;
  ObjectKindPolygon      =7;
  ObjectKindPolyline     =8;
  ObjectKindImage        =9;
  ObjectKindSetClipRect  =10;
  ObjectKindResetClipRect=11;

function GraphicObjectKind(aGraphicObject:TRLGraphicObject):TGraphicObjectKind;
begin
  if aGraphicObject is TRLPixelObject then
    Result:=ObjectKindPixel
  else if aGraphicObject is TRLLineObject then
    Result:=ObjectKindLine
  else if aGraphicObject is TRLRectangleObject then
    Result:=ObjectKindRectangle
  else if aGraphicObject is TRLTextObject then
    Result:=ObjectKindText
  else if aGraphicObject is TRLFillRectObject then
    Result:=ObjectKindFillRect
  else if aGraphicObject is TRLEllipseObject then
    Result:=ObjectKindEllipse
  else if aGraphicObject is TRLPolygonObject then
    Result:=ObjectKindPolygon
  else if aGraphicObject is TRLPolylineObject then
    Result:=ObjectKindPolyline
  else if aGraphicObject is TRLImageObject then
    Result:=ObjectKindImage
  else if aGraphicObject is TRLSetClipRectObject then
    Result:=ObjectKindSetClipRect
  else if aGraphicObject is TRLResetClipRectObject then
    Result:=ObjectKindResetClipRect
  else
    Result:=0;  
end;

const
  MaxSurfaceHeader=20;
  SurfaceHeaderStr='RLGraphicSurface3'#26;
  
procedure TRLGraphicSurface.SaveToStream(aStream:TStream);
  procedure SaveHeaderToStream(aStream:TStream);
  var
    data: AnsiString;
  begin
    data := SurfaceHeaderStr;
    aStream.Write(data[1],Length(data));
  end;
  function SaveBoundsToStream(aStream: TStream):integer;
  begin
    // guarda posi��o inicial de grava��o
    Result := aStream.Position;
    aStream.Write(fWidth ,SizeOf(fWidth));
    aStream.Write(fHeight,SizeOf(fHeight));
  end;
  procedure SaveMacrosToStream(aStream: TStream);
  var
    count,len,i: Integer;
    ln: AnsiString;
  begin
    // grava a quantidade de macros
    count := fMacros.Count;
    aStream.Write(count,SizeOf(count));
    // grava s�mbolos
    for i := 0 to count -1 do
    begin
      ln  := AnsiString(fMacros[i]);
      len := Length(ln);
      aStream.Write(len,SizeOf(len));
      aStream.Write(ln[1],len);
    end;
  end;
  function SaveFontsToStream(aStream:TStream):integer;
  var
    count,len,i: Integer;
    name: AnsiString;
  begin
    // guarda posi��o inicial de grava��o
    Result:=aStream.Position;
    //
    count := fFonts.Count;
    aStream.Write(count,SizeOf(count));
    // grava nomes das fontes
    for i:=0 to count-1 do
    begin
      name:=AnsiString(fFonts[i]);//bds2010
      len :=Length(name);
      // grava length + nome
      aStream.Write(len,SizeOf(len));
      aStream.Write(name[1],len);
    end;
  end;
  function SaveObjectToStream(aStream:TStream; aObject:TRLGraphicObject):integer;
  var
    kind      :TGraphicObjectKind;
    size      :integer;
    sizeoffset:integer;
    dataoffset:integer;
    endpos    :integer;
  begin
    // guarda posi��o inicial de grava��o
    Result:=aStream.Position;
    // grava tipo
    kind:=GraphicObjectKind(aObject);
    aStream.Write(kind,SizeOf(kind));
    // reserva tamanho
    sizeoffset:=aStream.Position;
    size:=0;
    aStream.Write(size,SizeOf(size));
    // grava objeto
    dataoffset:=aStream.Position;
    aObject.SaveToStream(aStream);
    // ajusta tamanho
    endpos:=aStream.Position;
    size  :=endpos-dataoffset;
    aStream.Position:=sizeoffset;
    aStream.Write(size,SizeOf(size));
    // restaura eof
    aStream.Position:=endpos;
  end;
  procedure SaveObjectsToStream(aStream:TStream);
  var
    count,i:integer;
  begin
    count:=ObjectCount;
    aStream.Write(count,SizeOf(count));
    // grava dados dos objetos
    for i:=0 to count-1 do
      SaveObjectToStream(aStream,Objects[i]);
  end;
begin
  SaveHeaderToStream(aStream);
  SaveBoundsToStream(aStream);
  SaveMacrosToStream(aStream);
  SaveFontsToStream(aStream);
  SaveObjectsToStream(aStream);
end;

function GraphicObjectClass(aGraphicObjectKind:TGraphicObjectKind):TRLGraphicObjectClass;
begin
  case aGraphicObjectKind of
    ObjectKindPixel        : Result:=TRLPixelObject;
    ObjectKindLine         : Result:=TRLLineObject;
    ObjectKindRectangle    : Result:=TRLRectangleObject;
    ObjectKindText         : Result:=TRLTextObject;
    ObjectKindFillRect     : Result:=TRLFillRectObject;
    ObjectKindEllipse      : Result:=TRLEllipseObject;
    ObjectKindPolygon      : Result:=TRLPolygonObject;
    ObjectKindPolyline     : Result:=TRLPolylineObject;
    ObjectKindImage        : Result:=TRLImageObject;
    ObjectKindSetClipRect  : Result:=TRLSetClipRectObject;
    ObjectKindResetClipRect: Result:=TRLResetClipRectObject;
  else
    Result:=nil;
  end;
end;

procedure TRLGraphicSurface.LoadFromStream(aStream:TStream);
  procedure LoadHeaderFromStream(aStream:TStream);
  var
    data: AnsiString;
    ch  : AnsiChar;
    i   : Integer;
  begin
    SetLength(data,MaxSurfaceHeader);
    i:=0;
    while (i<MaxSurfaceHeader) and (aStream.Read(ch,1)=1) do
    begin
      Inc(i);
      data[i] := ch;
      if ch=#26 then
        break;
    end;
    SetLength(data,i);
    if data<>SurfaceHeaderStr then
      raise Exception.Create('File is corrupted!');
  end;
  procedure LoadBoundsFromStream(aStream: TStream);
  begin
    aStream.Read(fWidth ,SizeOf(fWidth));
    aStream.Read(fHeight,SizeOf(fHeight));
  end;
  procedure LoadMacrosFromStream(aStream:TStream);
  var
    count,len,i:integer;
    ln: AnsiString;
  begin
    aStream.Read(count,SizeOf(count));
    // grava s�mbolos e seus valores
    for i:=0 to count-1 do
    begin
      // l� length + nome
      aStream.Read(len,SizeOf(len));
      SetLength(ln,len);
      aStream.Read(ln[1],len);
      //
      fMacros.Add(String(ln));//bds2010
    end;
  end;
  procedure LoadFontsFromStream(aStream:TStream);
  var
    count,len,i:integer;
    name: AnsiString;
  begin
    aStream.Read(count,SizeOf(count));
    // carrega nomes das fontes
    for i:=0 to count-1 do
    begin
      aStream.Read(len,SizeOf(len));
      SetLength(name,len);
      aStream.Read(name[1],len);
      fFonts.Add(String(name));//bds2010
    end;
  end;
  procedure LoadObjectsFromStream(aStream:TStream);
  var
    count  :integer;
    size   :integer;
    kind   :TGraphicObjectKind;
    creator:TRLGraphicObjectClass;
    i      :integer;
  begin
    aStream.Read(count,SizeOf(count));
    for i:=0 to count-1 do
    begin
      aStream.Read(kind,SizeOf(kind));
      aStream.Read(size,SizeOf(size));
      creator:=GraphicObjectClass(kind);
      // se a classe n�o for conhecida, salta o segmento
      if creator<>nil then
        creator.Create(Self).LoadFromStream(aStream)
      else
        aStream.Position:=aStream.Position+size;
    end;
  end;
begin
  Clear;
  LoadHeaderFromStream(aStream);
  LoadBoundsFromStream(aStream);
  LoadMacrosFromStream(aStream);
  LoadFontsFromStream(aStream);
  LoadObjectsFromStream(aStream);
  fModified:=False;
end;

function TRLGraphicSurface.GetObjectCount:integer;
begin
  Result:=fObjects.Count;
end;

function TRLGraphicSurface.GetObjects(aIndex:integer):TRLGraphicObject;
begin
  Result:=TRLGraphicObject(fObjects[aIndex]);
end;

function TRLGraphicSurface.FindFreeRow(aNearRow:integer; var aRow:integer):boolean;
var
  i:integer;
  g:TRLGraphicObject;
  b:boolean;
begin
  aRow:=aNearRow;
  repeat
    b:=false;
    for i:=0 to ObjectCount-1 do
    begin
      g:=Objects[i];
      if (g is TRLTextObject) and ((TRLTextObject(g).TextFlags and MetaTextFlagIntegralHeight)=MetaTextFlagIntegralHeight) then
        if (aRow>g.BoundsRect.Top) and (aRow<g.BoundsRect.Bottom) then
        begin
          aRow:=g.BoundsRect.Top;
          b   :=true;
        end;
    end;
  until not b or (aRow<=0);
  Result:=(aRow>0);
end;

procedure TRLGraphicSurface.Open;
begin
  if not fOpened then
  begin
    fOpened     :=true;
    fPenPos     :=Point(fMargins.Left,fMargins.Top);
    fGeneratorId:=0;
    fClipRect   :=Rect(0,0,fWidth,fHeight);
    fClipStack.Clear;
  end;
end;

procedure TRLGraphicSurface.Close;
begin
  if fOpened then
    fOpened:=false;
end;

procedure TRLGraphicSurface.Clear;
begin
  fObjects.Clear;
  fFonts.Clear;
  fMacros.Clear;
  //
  fPenPos     :=Point(0,0);
  fModified   :=true;
  fGeneratorId:=0;
end;

procedure TRLGraphicSurface.Ellipse(const aRect:TRect);
var
  obj:TRLEllipseObject;
begin
  Open;
  fModified:=true;
  obj:=TRLEllipseObject.Create(Self);
  obj.BoundsRect:=ToMetaRect(aRect);
  ToMetaPen(Self.Pen,obj.Pen);
  ToMetaBrush(Self.Brush,obj.Brush);
end;

procedure TRLGraphicSurface.Ellipse(aX1,aY1,aX2,aY2:integer);
begin
  Ellipse(Rect(aX1,aY1,aX2,aY2));
end;

procedure TRLGraphicSurface.FillRect(const aRect:TRect);
var
  obj:TRLFillRectObject;
begin
  Open;
  fModified:=true;
  obj:=TRLFillRectObject.Create(Self);
  obj.BoundsRect:=ToMetaRect(aRect);
  ToMetaBrush(Self.Brush,obj.Brush);
end;

procedure TRLGraphicSurface.MoveTo(aX,aY:integer);
begin
  Open;
  fModified:=true;
  fPenPos:=Point(aX,aY);
end;

procedure TRLGraphicSurface.LineTo(aX,aY:integer);
var
  obj:TRLLineObject;
begin
  Open;
  fModified:=true;
  obj:=TRLLineObject.Create(Self);
  obj.FromPoint :=ToMetaPoint(fPenPos);
  fPenPos       :=Point(aX,aY);
  obj.ToPoint   :=ToMetaPoint(fPenPos);
  obj.BoundsRect:=ToMetaRect(Rect(Min(obj.FromPoint.X,obj.ToPoint.X)-1,
                                  Min(obj.FromPoint.Y,obj.ToPoint.Y)-1,
                                  Max(obj.FromPoint.X,obj.ToPoint.X)+1,
                                  Max(obj.FromPoint.Y,obj.ToPoint.Y)+1));
  ToMetaPen(Self.Pen,obj.Pen);
  ToMetaBrush(Self.Brush,obj.Brush);
end;

procedure TRLGraphicSurface.Polygon(const aPoints:array of TPoint);
var
  obj:TRLPolygonObject;
begin
  Open;
  fModified:=true;
  obj:=TRLPolygonObject.Create(Self);
  obj.Points    :=ToMetaPointArray(aPoints);
  obj.BoundsRect:=ToMetaRect(GetPointsBounds(obj.Points));
  ToMetaPen(Self.Pen,obj.Pen);
  ToMetaBrush(Self.Brush,obj.Brush);
end;

procedure TRLGraphicSurface.Polyline(const aPoints:array of TPoint);
var
  obj:TRLPolylineObject;
begin
  Open;
  fModified:=true;
  obj:=TRLPolylineObject.Create(Self);
  obj.Points    :=ToMetaPointArray(aPoints);
  obj.BoundsRect:=ToMetaRect(GetPointsBounds(obj.Points));
  ToMetaPen(Self.Pen,obj.Pen);
end;

procedure TRLGraphicSurface.Rectangle(aLeft,aTop,aRight,aBottom:integer);
var
  obj:TRLRectangleObject;
begin
  Open;
  fModified:=true;
  obj:=TRLRectangleObject.Create(Self);
  obj.BoundsRect:=ToMetaRect(Rect(aLeft,aTop,aRight,aBottom));
  ToMetaPen(Self.Pen,obj.Pen);
  ToMetaBrush(Self.Brush,obj.Brush);
end;

procedure TRLGraphicSurface.Rectangle(const aRect:TRect);
begin
  with aRect do
    Rectangle(Left,Top,Right,Bottom);
end;

procedure TRLGraphicSurface.SetClipRect(const aRect:TRect);
var
  obj:TRLSetClipRectObject;
begin
  Open;
  fModified:=true;
  obj:=TRLSetClipRectObject.Create(Self);
  obj.BoundsRect:=ToMetaRect(aRect);
  PushClipRect(fClipRect);
  fClipRect:=aRect;
end;

procedure TRLGraphicSurface.ResetClipRect;
var
  obj:TRLResetClipRectObject;
begin
  Open;
  fModified:=true;
  obj:=TRLResetClipRectObject.Create(Self);
  obj.BoundsRect:=ToMetaRect(fClipRect);
  PopClipRect(fClipRect);
end;

procedure TRLGraphicSurface.PaintTo(aCanvas:TCanvas; aRect:TRect);
var
  xfactor,yfactor:double;
  i:integer;
begin
  if fWidth=0 then
    xfactor:=1
  else
    xfactor:=(aRect.Right-aRect.Left)/fWidth;
  if fHeight=0 then
    yfactor:=1
  else
    yfactor:=(aRect.Bottom-aRect.Top)/fHeight;
  //
  fClipStack.Clear;
  try
    fClipRect := aRect;
    CanvasStart(aCanvas);
    try
      CanvasSetClipRect(aCanvas,fClipRect);
      try
        for i:=0 to ObjectCount-1 do
          Objects[i].PaintTo(aCanvas,xfactor,yfactor,aRect.Left,aRect.Top);
      finally
        CanvasResetClipRect(aCanvas);
      end;
    finally
      CanvasStop(aCanvas);
    end;
  finally
    while fClipStack.Count > 0 do
      PopClipRect(fClipRect);
  end;
end;

procedure TRLGraphicSurface.CopyRect(const aDest:TRect; aCanvas:TCanvas; const aSource:TRect);
var
  b:TBitmap;
begin
  b:=TBitmap.Create;
  try
    b.Width :=aSource.Right-aSource.Left;
    b.Height:=aSource.Bottom-aSource.Top;
    b.PixelFormat:=pf32bit;
    b.Canvas.CopyRect(Rect(0,0,b.Width,b.Height),aCanvas,aSource);
    StretchDraw(aDest,b);
  finally
    b.free;
  end;
end;

procedure TRLGraphicSurface.CopyRect(const aDest:TRect; aSurface:TRLGraphicSurface; const aSource:TRect);
var
  xfactor,yfactor:double;
  xdesloc,ydesloc:integer;
  obj,clone:TRLGraphicObject;
  p:TRLMetaRect;
  r:TRect;
  i:integer;
begin
  Open;
  fModified:=true;
  xfactor:=(aDest.Right-aDest.Left)/(aSource.Right-aSource.Left);
  yfactor:=(aDest.Bottom-aDest.Top)/(aSource.Bottom-aSource.Top);
  xdesloc:=aDest.Left-Round(aSource.Left*xfactor);
  ydesloc:=aDest.Top-Round(aSource.Top*yfactor);
  //
  SetClipRect(aDest);
  try
    for i:=0 to aSurface.ObjectCount-1 do
    begin
      obj:=aSurface.Objects[i];
      p:=obj.fBoundsRect;
      r.Left  :=p.Left;
      r.Top   :=p.Top;
      r.Right :=p.Right;
      r.Bottom:=p.Bottom;
      if IntersectRect(r,aSource,r) then
      begin
        clone:=obj.Clone(Self);
        clone.Inflate(xfactor,yfactor);
        clone.Offset(xdesloc,ydesloc);
      end;
    end;
  finally
    ResetClipRect;
  end;
end;

procedure TRLGraphicSurface.SetFont(const Value:TFont);
begin
  fFont.Assign(Value);
end;

procedure TRLGraphicSurface.SetPen(const Value:TPen);
begin
  fPen.Assign(Value);
end;

procedure TRLGraphicSurface.SetBrush(const Value:TBrush);
begin
  fBrush.Assign(Value);
end;

function TRLGraphicSurface.GetPixels(X,Y:integer):TColor;
begin
  Result:=Self.Brush.Color;
end;

procedure TRLGraphicSurface.SetPixels(X,Y:integer; const Value:TColor);
var
  obj:TRLPixelObject;
begin
  Open;
  fModified:=true;
  obj:=TRLPixelObject.Create(Self);
  obj.BoundsRect:=ToMetaRect(Rect(X,Y,X+1,Y+1));
  obj.Color     :=ToMetaColor(Value);
end;

procedure TRLGraphicSurface.SetStorage(aStorage: TRLGraphicStorage);
begin
  if fStorage<>aStorage then
  begin
    if Assigned(fStorage) then
      fStorage.fPageCache.Extract(Self);
    fStorage:=aStorage;
  end;  
end;

procedure TRLGraphicSurface.BitmapAuxNeeded;
begin
  if not Assigned(fBitmapAux) then
  begin
    fBitmapAux:=TBitmap.Create;
    fBitmapAux.Width :=1;
    fBitmapAux.Height:=1;
  end;
end;

function TRLGraphicSurface.TextWidth(const aText:String):integer;
begin
  BitmapAuxNeeded;
  fBitmapAux.Canvas.Font.Assign(fFont);
  Result:=fBitmapAux.Canvas.TextWidth(aText);
end;

function TRLGraphicSurface.TextHeight(const aText:String):integer;
begin
  BitmapAuxNeeded;
  fBitmapAux.Canvas.Font.Assign(fFont);
  Result:=fBitmapAux.Canvas.TextHeight(aText);
end;

procedure TRLGraphicSurface.TextOut(aLeft,aTop:integer; const aText:AnsiString);
begin
  TextOutEx(aLeft,aTop,aText,MetaTextFlagAutoSize or MetaTextFlagIntegralHeight);
end;

procedure TRLGraphicSurface.TextOutEx(aLeft,aTop:integer; const aText:AnsiString; aTextFlags:TRLMetaTextFlags);
var
  obj:TRLTextObject;
begin
  Open;
  fModified:=true;
  obj:=TRLTextObject.Create(Self);
  obj.BoundsRect:=ToMetaRect(Rect(aLeft,aTop,aLeft+TextWidth(String(aText)),aTop+TextHeight(String(aText))));//bds2010
  obj.Text      :=aText;
  obj.Origin    :=ToMetaPoint(Point(aLeft,aTop));
  obj.Alignment :=MetaTextAlignmentLeft;
  obj.Layout    :=MetaTextLayoutTop;
  obj.TextFlags :=aTextFlags;
  ToMetaBrush(Self.Brush,obj.Brush);
  ToMetaFont(Self.Font,obj.Font);
end;

procedure TRLGraphicSurface.TextRect(const aRect:TRect; aLeft,aTop:integer; const aText:AnsiString);
begin
  TextRectEx(aRect,aLeft,aTop,aText,MetaTextAlignmentLeft,MetaTextLayoutTop,MetaTextFlagIntegralHeight);
end;

procedure TRLGraphicSurface.TextRectEx(const aRect:TRect; aLeft,aTop:integer; const aText:AnsiString; aAlignment:TRLMetaTextAlignment; aLayout:TRLMetaTextLayout; aTextFlags:TRLMetaTextFlags);
var
  obj:TRLTextObject;
begin
  Open;
  fModified:=true;
  obj:=TRLTextObject.Create(Self);
  obj.BoundsRect:=ToMetaRect(aRect);
  obj.Text      :=aText;
  obj.Origin    :=ToMetaPoint(Point(aLeft,aTop));
  obj.Alignment :=aAlignment;
  obj.Layout    :=aLayout;
  obj.TextFlags :=aTextFlags;
  ToMetaBrush(Self.Brush,obj.Brush);
  ToMetaFont(Self.Font,obj.Font);
end;

procedure TRLGraphicSurface.Write(const aText:AnsiString);
begin
  TextOut(fPenPos.x,fPenPos.y,aText);
  Inc(fPenPos.x,TextWidth(String(aText)));//bds2010
end;

procedure TRLGraphicSurface.WriteLn(const aText:AnsiString);
begin
  TextOut(fPenPos.x,fPenPos.y,aText);
  fPenPos.x:=fMargins.Left;
  Inc(fPenPos.y,TextHeight(String(aText)));//bds2010
end;

procedure TRLGraphicSurface.Draw(aX,aY:integer; aGraphic:TGraphic; aParity:boolean=false);
var
  obj:TRLImageObject;
begin
  Open;
  fModified:=True;
  obj:=TRLImageObject.Create(Self);
  obj.BoundsRect:=ToMetaRect(Rect(aX,aY,aX+aGraphic.Width,aY+aGraphic.Height));
  obj.Data      :=AnsiString(ToMetaGraphic(aGraphic));//bds2010
  obj.Parity    :=aParity;
end;

procedure TRLGraphicSurface.Draw(aX,aY:integer; aSurface:TRLGraphicSurface);
var
  i:integer;
begin
  Open;
  fModified:=true;
  for i:=0 to aSurface.ObjectCount-1 do
    aSurface.Objects[i].Clone(Self).Offset(aX,aY);
end;

procedure TRLGraphicSurface.StretchDraw(const aRect:TRect; aGraphic:TGraphic; aParity:boolean=false);
var
  obj:TRLImageObject;
begin
  Open;
  fModified:=true;
  obj:=TRLImageObject.Create(Self);
  obj.BoundsRect:=ToMetaRect(aRect);
  obj.Data      :=AnsiString(ToMetaGraphic(aGraphic));//bds2010
  obj.Parity    :=aParity;
end;

procedure TRLGraphicSurface.StretchDraw(const aRect:TRect; aSurface:TRLGraphicSurface);
begin
  CopyRect(aRect,aSurface,Rect(0,0,aSurface.Width,aSurface.Height));
end;

procedure TRLGraphicSurface.ScaleDraw(const aRect:TRect; aGraphic:TGraphic; aCenter:boolean);
var
  scaledrect:TRect;
begin
  scaledrect:=ScaleRect(Rect(0,0,aGraphic.Width,aGraphic.Height),aRect,aCenter);
  StretchDraw(scaledrect,aGraphic);
end;

procedure TRLGraphicSurface.ScaleDraw(const aRect:TRect; aSurface:TRLGraphicSurface; aCenter:boolean);
var
  scaledrect:TRect;
begin
  scaledrect:=ScaleRect(Rect(0,0,aSurface.Width,aSurface.Height),aRect,aCenter);
  StretchDraw(scaledrect,aSurface);
end;

procedure TRLGraphicSurface.ClipDraw(const aRect:TRect; aGraphic:TGraphic; aCenter:boolean);
var
  b:TBitmap;
  r:TRect;
begin
  r:=aRect;
  b:=ClipGraphic(aGraphic,r,aCenter);
  if Assigned(b) then
    try
      StretchDraw(r,b);
    finally
      b.free;
    end;
end;

procedure TRLGraphicSurface.ClipDraw(const aRect:TRect; aSurface:TRLGraphicSurface; aCenter:boolean);
var
  b:TRLGraphicSurface;
  r:TRect;
begin
  r:=aRect;
  b:=ClipSurface(aSurface,r,aCenter);
  if Assigned(b) then
    try
      StretchDraw(r,b);
    finally
      b.free;
    end;
end;

procedure TRLGraphicSurface.PushClipRect(const aRect:TRect);
var
  p:PRect;
begin
  New(p);
  p^:=aRect;
  fClipStack.Insert(0,p);
end;

procedure TRLGraphicSurface.PopClipRect(var aRect:TRect);
var
  p:PRect;
begin
  p:=fClipStack[0];
  aRect:=p^;
  Dispose(p);
  fClipStack.Delete(0);
end;

function TRLGraphicSurface.GetOrientation: TRLMetaOrientation;
begin
  Result:=StrToIntDef(fMacros.Values['Orientation'],MetaOrientationPortrait);
end;

procedure TRLGraphicSurface.SetOrientation(const Value: TRLMetaOrientation);
begin
  fMacros.Values['Orientation']:=IntToStr(Value);
end;

function TRLGraphicSurface.GetPaperHeight: double;
begin
  Result:=PtStrToFloat(fMacros.Values['PaperHeight'],0);
  if Result<0 then
    Result:=-1;
end;

procedure TRLGraphicSurface.SetPaperHeight(const Value: double);
begin
  fMacros.Values['PaperHeight']:=String(FloatToPtStr(IfThen(Value<0,-1,Value)));//bds2010
end;

function TRLGraphicSurface.GetPaperWidth: double;
begin
  Result:=PtStrToFloat(fMacros.Values['PaperWidth'],0);
  if Result<0 then
    Result:=-1;
end;

procedure TRLGraphicSurface.SetPaperWidth(const Value: double);
begin
  fMacros.Values['PaperWidth']:=String(FloatToPtStr(IfThen(Value<0,-1,Value)));//bds2010
end;

function TRLGraphicSurface.GetOrientedPaperHeight: double;
begin
  if Orientation=MetaOrientationPortrait then
    Result:=PaperHeight
  else
    Result:=PaperWidth;
end;

function TRLGraphicSurface.GetOrientedPaperWidth: double;
begin
  if Orientation=MetaOrientationPortrait then
    Result:=PaperWidth
  else
    Result:=PaperHeight;
end;

function TRLGraphicSurface.GetOrientedHeight: integer;
begin
  if Orientation=MetaOrientationPortrait then
    Result:=Height
  else
    Result:=Width;
end;

function TRLGraphicSurface.GetOrientedWidth: integer;
begin
  if Orientation=MetaOrientationPortrait then
    Result:=Width
  else
    Result:=Height;
end;

{ TRLMetaPen }

constructor TRLMetaPen.Create(aUser:TRLGraphicObject);
begin
  fUser  :=aUser;
  fColor :=MetaColor(0,0,0);
  fMode  :=MetaPenModeCopy;
  fStyle :=MetaPenStyleSolid;
  fWidth :=0;
  //
  inherited Create;
end;

procedure TRLMetaPen.SaveToStream(aStream:TStream);
begin
  aStream.Write(fColor,SizeOf(fColor));
  aStream.Write(fMode ,SizeOf(fMode));
  aStream.Write(fStyle,SizeOf(fStyle));
  aStream.Write(fWidth,SizeOf(fWidth));
end;

procedure TRLMetaPen.LoadFromStream(aStream:TStream);
begin
  aStream.Read(fColor,SizeOf(fColor));
  aStream.Read(fMode ,SizeOf(fMode));
  aStream.Read(fStyle,SizeOf(fStyle));
  aStream.Read(fWidth,SizeOf(fWidth));
end;

procedure TRLMetaPen.Assign(aObject:TRLMetaPen);
begin
  Color:=aObject.Color;
  Mode :=aObject.Mode;
  Style:=aObject.Style;
  Width:=aObject.Width;
end;

procedure TRLMetaPen.Inflate(aFactor: double);
begin
  if Width<>0 then
    Width:=Max(1,Round(Width*aFactor));
end;

function TRLMetaPen.GetColor: TRLMetaColor;
begin
  Result:=fColor;
end;

function TRLMetaPen.GetMode: TRLMetaPenMode;
begin
  Result:=fMode;
end;

function TRLMetaPen.GetStyle: TRLMetaPenStyle;
begin
  Result:=fStyle;
end;

function TRLMetaPen.GetWidth: integer;
begin
  Result:=fWidth;
end;

procedure TRLMetaPen.SetColor(const Value: TRLMetaColor);
begin
  fColor:=Value;
end;

procedure TRLMetaPen.SetMode(Value: TRLMetaPenMode);
begin
  fMode:=Value;
end;

procedure TRLMetaPen.SetStyle(Value: TRLMetaPenStyle);
begin
  fStyle:=Value;
end;

procedure TRLMetaPen.SetWidth(Value: integer);
begin
  fWidth:=Value;
end;

{ TRLMetaBrush }

constructor TRLMetaBrush.Create(aUser:TRLGraphicObject);
begin
  fUser :=aUser;
  fColor:=MetaColor(0,0,0);
  fStyle:=MetaBrushStyleSolid;
  //
  inherited Create;
end;

procedure TRLMetaBrush.SaveToStream(aStream:TStream);
begin
  aStream.Write(fColor,SizeOf(fColor));
  aStream.Write(fStyle,SizeOf(fStyle));
end;

procedure TRLMetaBrush.LoadFromStream(aStream:TStream);
begin
  aStream.Read(fColor,SizeOf(fColor));
  aStream.Read(fStyle,SizeOf(fStyle));
end;

procedure TRLMetaBrush.Assign(aObject:TRLMetaBrush);
begin
  Color:=aObject.Color;
  Style:=aObject.Style;
end;

function TRLMetaBrush.GetColor: TRLMetaColor;
begin
  Result:=fColor;
end;

function TRLMetaBrush.GetStyle: TRLMetaBrushStyle;
begin
  Result:=fStyle;
end;

procedure TRLMetaBrush.SetColor(const Value: TRLMetaColor);
begin
  fColor:=Value;
end;

procedure TRLMetaBrush.SetStyle(Value: TRLMetaBrushStyle);
begin
  fStyle:=Value;
end;

{ TRLMetaFont }

constructor TRLMetaFont.Create(aUser:TRLGraphicObject);
begin
  fUser         :=aUser;
  fPixelsPerInch:=72;
  fCharset      :=0;
  fColor        :=MetaColor(0,0,0);
  fHeight       :=0;
  fNameId       :=0;
  fPitch        :=MetaFontPitchDefault;
  fSize         :=0;
  fStyle        :=0;
  //
  inherited Create;
end;

procedure TRLMetaFont.SaveToStream(aStream:TStream);
begin
  aStream.Write(fPixelsPerInch,SizeOf(fPixelsPerInch));
  aStream.Write(fCharset      ,SizeOf(fCharset));
  aStream.Write(fColor        ,SizeOf(fColor));
  aStream.Write(fHeight       ,SizeOf(fHeight));
  aStream.Write(fNameId       ,SizeOf(fNameId));
  aStream.Write(fPitch        ,SizeOf(fPitch));
  aStream.Write(fSize         ,SizeOf(fSize));
  aStream.Write(fStyle        ,SizeOf(fStyle));
end;

procedure TRLMetaFont.LoadFromStream(aStream:TStream);
begin
  aStream.Read(fPixelsPerInch,SizeOf(fPixelsPerInch));
  aStream.Read(fCharset      ,SizeOf(fCharset));
  aStream.Read(fColor        ,SizeOf(fColor));
  aStream.Read(fHeight       ,SizeOf(fHeight));
  aStream.Read(fNameId       ,SizeOf(fNameId));
  aStream.Read(fPitch        ,SizeOf(fPitch));
  aStream.Read(fSize         ,SizeOf(fSize));
  aStream.Read(fStyle        ,SizeOf(fStyle));
end;

procedure TRLMetaFont.Assign(aObject:TRLMetaFont);
begin
  PixelsPerInch:=aObject.PixelsPerInch;
  Charset      :=aObject.Charset;
  Color        :=aObject.Color;
  Height       :=aObject.Height;
  Name         :=aObject.Name;
  Pitch        :=aObject.Pitch;
  Size         :=aObject.Size;
  Style        :=aObject.Style;
end;

function TRLMetaFont.GetName:String;
begin
  Result:=fUser.fSurface.fFonts[fNameId];
end;

procedure TRLMetaFont.SetName(const Value:String);
begin
  fNameId:=fUser.fSurface.fFonts.IndexOf(Value);
  if fNameId=-1 then
    fNameId:=fUser.fSurface.fFonts.Add(Value);
end;

function TRLMetaFont.GetCharset: TRLMetaFontCharset;
begin
  Result:=fCharset;
end;

function TRLMetaFont.GetColor: TRLMetaColor;
begin
  Result:=fColor;
end;

function TRLMetaFont.GetHeight: integer;
begin
  Result:=fHeight;
end;

function TRLMetaFont.GetPitch: TRLMetaFontPitch;
begin
  Result:=fPitch;
end;

function TRLMetaFont.GetPixelsPerInch: integer;
begin
  Result:=fPixelsPerInch;
end;

function TRLMetaFont.GetSize: integer;
begin
  Result:=fSize;
end;

function TRLMetaFont.GetStyle: TRLMetaFontStyles;
begin
  Result:=fStyle;
end;

procedure TRLMetaFont.SetCharset(Value: TRLMetaFontCharset);
begin
  fCharset:=Value;
end;

procedure TRLMetaFont.SetColor(const Value: TRLMetaColor);
begin
  fColor:=Value;
end;

procedure TRLMetaFont.SetHeight(Value: integer);
begin
  fHeight:=Value;
end;

procedure TRLMetaFont.SetPitch(Value: TRLMetaFontPitch);
begin
  fPitch:=Value;
end;

procedure TRLMetaFont.SetPixelsPerInch(Value: integer);
begin
  fPixelsPerInch:=Value;
end;

procedure TRLMetaFont.SetSize(Value: integer);
begin
  fSize:=Value;
end;

procedure TRLMetaFont.SetStyle(Value: TRLMetaFontStyles);
begin
  fStyle:=Value;
end;

{ TRLGraphicObject }

constructor TRLGraphicObject.Create(aSurface:TRLGraphicSurface);
begin
  fSurface       :=aSurface;
  fBoundsRect    :=ToMetaRect(Rect(0,0,0,0));
  fGroupId       :=CurrentGroupId;
  fGeneratorId   :=0;
  fTag           :=0;
  //
  inherited Create;
  //
  fSurface.fObjects.Add(Self);
end;

destructor TRLGraphicObject.Destroy;
begin
  fSurface.fObjects.Extract(Self);
  //
  inherited;
end;

procedure TRLGraphicObject.SaveToStream(aStream:TStream);
begin
  aStream.Write(fBoundsRect,SizeOf(fBoundsRect));
  aStream.Write(fGroupId,SizeOf(fGroupId));
  aStream.Write(fGeneratorId,SizeOf(fGeneratorId));
end;

procedure TRLGraphicObject.LoadFromStream(aStream:TStream);
begin
  aStream.Read(fBoundsRect,SizeOf(fBoundsRect));
  aStream.Read(fGroupId,SizeOf(fGroupId));
  aStream.Read(fGeneratorId,SizeOf(fGeneratorId));
end;

function TRLGraphicObject.Clone(aSurface: TRLGraphicSurface): TRLGraphicObject;
begin
  Result:=TRLGraphicObjectClass(Self.ClassType).Create(aSurface);
  Result.Assign(Self);
end;

procedure TRLGraphicObject.Assign(aObject: TRLGraphicObject); 
begin
  BoundsRect :=aObject.BoundsRect;
  GroupId    :=aObject.GroupId;
  GeneratorId:=aObject.GeneratorId;
end;

procedure TRLGraphicObject.Offset(aXDesloc,aYDesloc: integer);
begin
  Inc(fBoundsRect.Left  ,aXDesloc);
  Inc(fBoundsRect.Top   ,aYDesloc);
  Inc(fBoundsRect.Right ,aXDesloc);
  Inc(fBoundsRect.Bottom,aYDesloc);
end;

procedure TRLGraphicObject.Inflate(aXFactor, aYFactor: double);
begin
  fBoundsRect.Left  :=Round(fBoundsRect.Left  *aXFactor);
  fBoundsRect.Top   :=Round(fBoundsRect.Top   *aYFactor);
  fBoundsRect.Right :=Round(fBoundsRect.Right *aXFactor);
  fBoundsRect.Bottom:=Round(fBoundsRect.Bottom*aYFactor);
end;

{ TRLPixelObject }

constructor TRLPixelObject.Create(aSurface:TRLGraphicSurface);
begin
  fColor:=ToMetaColor(clBlack);
  //
  inherited;
end;

procedure TRLPixelObject.SaveToStream(aStream:TStream);
begin
  inherited;
  //
  aStream.Write(fColor,SizeOf(fColor));
end;

procedure TRLPixelObject.LoadFromStream(aStream:TStream);
begin
  inherited;
  //
  aStream.Read(fColor,SizeOf(fColor));
end;

procedure TRLPixelObject.PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer);
var
  r:TRect;
begin
  r.Left  :=aXDesloc+Round(fBoundsRect.Left*aXFactor);
  r.Top   :=aYDesloc+Round(fBoundsRect.Top *aYFactor);
  r.Right :=Max(aXDesloc+Round(fBoundsRect.Right *aXFactor),r.Left+1);
  r.Bottom:=Max(aYDesloc+Round(fBoundsRect.Bottom*aYFactor),r.Top +1);
  //
  aCanvas.Brush.Style:=bsSolid;
  aCanvas.Brush.Color:=FromMetaColor(fColor);
  aCanvas.FillRect(r);
end;

procedure TRLPixelObject.Assign(aObject: TRLGraphicObject); 
begin
  inherited Assign(aObject); 
  //
  Color:=TRLPixelObject(aObject).Color;
end;

{ TRLLineObject }

constructor TRLLineObject.Create(aSurface:TRLGraphicSurface);
begin
  fFromPoint:=MetaPoint(0,0);
  fToPoint  :=MetaPoint(0,0);
  fPen      :=nil;
  fBrush    :=nil;
  //
  fPen  :=TRLMetaPen.Create(Self);
  fBrush:=TRLMetaBrush.Create(Self);
  //
  inherited;
end;

destructor TRLLineObject.Destroy;
begin
  inherited;
  //
  if Assigned(fPen) then
    fPen.free;
  if Assigned(fBrush) then
    fBrush.free;
end;

procedure TRLLineObject.SaveToStream(aStream:TStream);
begin
  inherited;
  //
  aStream.Write(fFromPoint,SizeOf(fFromPoint));
  aStream.Write(fToPoint,SizeOf(fToPoint));
  fPen.SaveToStream(aStream);
  fBrush.SaveToStream(aStream);
end;

procedure TRLLineObject.LoadFromStream(aStream:TStream);
begin
  inherited;
  //
  aStream.Read(fFromPoint,SizeOf(fFromPoint));
  aStream.Read(fToPoint,SizeOf(fToPoint));
  fPen.LoadFromStream(aStream);
  fBrush.LoadFromStream(aStream);
end;

procedure TRLLineObject.PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer);
var
  p1,p2:TPoint;
begin
  p1.X:=aXDesloc+Round(fFromPoint.X*aXFactor);
  p1.Y:=aYDesloc+Round(fFromPoint.Y*aYFactor);
  p2.X:=aXDesloc+Round(fToPoint.X  *aXFactor);
  p2.Y:=aYDesloc+Round(fToPoint.Y  *aYFactor);
  //
  FromMetaPen(fPen,aCanvas.Pen);
  PenInflate(aCanvas.Pen,aXFactor);
  FromMetaBrush(fBrush,aCanvas.Brush);
  aCanvas.MoveTo(p1.X,p1.Y);
  CanvasLineToEx(aCanvas,p2.X,p2.Y);
end;

procedure TRLLineObject.Assign(aObject: TRLGraphicObject); 
begin
  inherited Assign(aObject);
  //
  FromPoint:=TRLLineObject(aObject).FromPoint;
  ToPoint  :=TRLLineObject(aObject).ToPoint;
  Pen      :=TRLLineObject(aObject).Pen;
  Brush    :=TRLLineObject(aObject).Brush;
end;

procedure TRLLineObject.Offset(aXDesloc,aYDesloc: integer); 
begin
  inherited Offset(aXDesloc,aYDesloc);
  //
  Inc(fFromPoint.X,aXDesloc);
  Inc(fFromPoint.Y,aYDesloc);
  Inc(fToPoint.X  ,aXDesloc);
  Inc(fToPoint.Y  ,aYDesloc);
end;

procedure TRLLineObject.Inflate(aXFactor, aYFactor: double);
begin
  inherited Inflate(aXFactor,aYFactor);
  //
  fFromPoint.X:=Round(fFromPoint.X*aXFactor);
  fFromPoint.Y:=Round(fFromPoint.Y*aYFactor);
  fToPoint.X  :=Round(fToPoint.X  *aXFactor);
  fToPoint.Y  :=Round(fToPoint.Y  *aYFactor);
  fPen.Inflate(aXFactor);
end;

procedure TRLLineObject.SetPen(Value:TRLMetaPen);
begin
  fPen.Assign(Value);
end;

procedure TRLLineObject.SetBrush(Value:TRLMetaBrush);
begin
  fBrush.Assign(Value);
end;

{ TRLRectangleObject }

constructor TRLRectangleObject.Create(aSurface:TRLGraphicSurface);
begin
  fPen  :=nil;
  fBrush:=nil;
  //
  fPen  :=TRLMetaPen.Create(Self);
  fBrush:=TRLMetaBrush.Create(Self);
  //
  inherited;
end;

destructor TRLRectangleObject.Destroy;
begin
  inherited;
  //
  if Assigned(fPen) then
    fPen.free;
  if Assigned(fBrush) then
    fBrush.free;
end;

procedure TRLRectangleObject.SaveToStream(aStream: TStream);
begin
  inherited;
  //
  fPen.SaveToStream(aStream);
  fBrush.SaveToStream(aStream);
end;

procedure TRLRectangleObject.LoadFromStream(aStream: TStream);
begin
  inherited;
  //
  fPen.LoadFromStream(aStream);
  fBrush.LoadFromStream(aStream);
end;

procedure TRLRectangleObject.PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer);
var
  r:TRect;
begin
  r.Left  :=aXDesloc+Round(fBoundsRect.Left*aXFactor);
  r.Top   :=aYDesloc+Round(fBoundsRect.Top *aYFactor);
  r.Right :=Max(aXDesloc+Round(fBoundsRect.Right *aXFactor),r.Left+1);
  r.Bottom:=Max(aYDesloc+Round(fBoundsRect.Bottom*aYFactor),r.Top +1);
  //
  FromMetaPen(fPen,aCanvas.Pen);
  PenInflate(aCanvas.Pen,aXFactor);
  FromMetaBrush(fBrush,aCanvas.Brush);
  aCanvas.Rectangle(r.Left,r.Top,r.Right,r.Bottom);
end;

procedure TRLRectangleObject.Assign(aObject: TRLGraphicObject);
begin
  inherited Assign(aObject);
  //
  Pen  :=TRLRectangleObject(aObject).Pen;
  Brush:=TRLRectangleObject(aObject).Brush;
end;

procedure TRLRectangleObject.Inflate(aXFactor, aYFactor: double);
begin
  inherited Inflate(aXFactor,aYFactor);
  //
  fPen.Inflate(aXFactor);
end;

procedure TRLRectangleObject.SetPen(Value:TRLMetaPen);
begin
  fPen.Assign(Value);
end;

procedure TRLRectangleObject.SetBrush(Value:TRLMetaBrush);
begin
  fBrush.Assign(Value);
end;

{ TRLTextObject }

constructor TRLTextObject.Create(aSurface:TRLGraphicSurface);
begin
  fAlignment:=MetaTextAlignmentLeft;
  fBrush    :=nil;
  fFont     :=nil;
  fLayout   :=MetaTextLayoutTop;
  fOrigin   :=MetaPoint(0,0);
  fText     :='';
  fTextFlags:=MetaTextFlagAutoSize or MetaTextFlagIntegralHeight;
  //
  fBrush:=TRLMetaBrush.Create(Self);
  fFont :=TRLMetaFont.Create(Self);
  //
  inherited;
end;

destructor TRLTextObject.Destroy;
begin
  inherited;
  //
  if Assigned(fBrush) then
    fBrush.free;
  if Assigned(fFont) then
    fFont.free;
end;

procedure TRLTextObject.SaveToStream(aStream: TStream);
var
  len:integer;
begin
  inherited;
  //
  aStream.Write(fAlignment,SizeOf(fAlignment));
  aStream.Write(fLayout,SizeOf(fLayout));
  aStream.Write(fOrigin,SizeOf(fOrigin));
  aStream.Write(fTextFlags,SizeOf(fTextFlags));
  //
  len:=Length(fText);
  aStream.Write(len,SizeOf(len));
  if len>0 then
    aStream.Write(fText[1],len);
  //
  fBrush.SaveToStream(aStream);
  fFont.SaveToStream(aStream);
end;

procedure TRLTextObject.LoadFromStream(aStream: TStream);
var
  len:integer;
begin
  inherited;
  //
  aStream.Read(fAlignment,SizeOf(fAlignment));
  aStream.Read(fLayout,SizeOf(fLayout));
  aStream.Read(fOrigin,SizeOf(fOrigin));
  aStream.Read(fTextFlags,SizeOf(fTextFlags));
  //
  aStream.Read(len,SizeOf(len));
  SetLength(fText,len);
  if len>0 then
    aStream.Read(fText[1],len);
  //
  fBrush.LoadFromStream(aStream);
  fFont.LoadFromStream(aStream);
end;

// processa macros
procedure TRLTextObject.TranslateMacros(var aText:String);
var
  keyword,keyvalue:String;
  macros1,macros2:TStrings;
  i,m:integer;
begin
  macros1:=fSurface.Macros;
  if Assigned(fSurface.fStorage) then
    macros2:=fSurface.fStorage.Macros
  else
    macros2:=nil;
  i:=1;
  while i<=Length(aText) do
    if aText[i]='{' then
    begin
      m:=i;
      while (i<=Length(aText)) and (aText[i]<>'}') do
        Inc(i);
      if i<=Length(aText) then
      begin
        keyword:=Copy(String(aText),m+1,i-(m+1));
        if macros1.IndexOfName(keyword)<>-1 then
          keyvalue:=macros1.Values[keyword]
        else if Assigned(macros2) and (macros2.IndexOfName(keyword)<>-1) then
          keyvalue:=macros2.Values[keyword]
        else
          continue;
        Delete(aText,m,i-m+1);
        Insert(keyvalue,String(aText),m);
        i:=m+Length(keyvalue);
      end;
    end
    else
      Inc(i);
end;

procedure TRLTextObject.PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer);
var
  r:TRect;
  o:TPoint;
  t:AnsiString;
begin
  r.Left  :=aXDesloc+Round(fBoundsRect.Left  *aXFactor);
  r.Top   :=aYDesloc+Round(fBoundsRect.Top   *aYFactor);
  r.Right :=aXDesloc+Round(fBoundsRect.Right *aXFactor);
  r.Bottom:=aYDesloc+Round(fBoundsRect.Bottom*aYFactor);
  o.X     :=aXDesloc+Round(fOrigin.X         *aXFactor);
  o.Y     :=aYDesloc+Round(fOrigin.Y         *aYFactor);
  //
  FromMetaBrush(fBrush,aCanvas.Brush);
  FromMetaFont(fFont,aCanvas.Font,aYFactor);
  t:=DisplayText;
  CanvasTextRectEx(aCanvas,r,o.X,o.Y,String(t),fAlignment,fLayout,fTextFlags);
end;

procedure TRLTextObject.Assign(aObject: TRLGraphicObject); 
begin
  inherited Assign(aObject);
  //
  Alignment:=TRLTextObject(aObject).Alignment;
  TextFlags:=TRLTextObject(aObject).TextFlags;
  Brush    :=TRLTextObject(aObject).Brush;
  Font     :=TRLTextObject(aObject).Font;
  Layout   :=TRLTextObject(aObject).Layout;
  Origin   :=TRLTextObject(aObject).Origin;
  Text     :=TRLTextObject(aObject).Text;
end;

procedure TRLTextObject.Offset(aXDesloc,aYDesloc: integer); 
begin
  inherited Offset(aXDesloc,aYDesloc);
  //
  Inc(fOrigin.X,aXDesloc);
  Inc(fOrigin.Y,aYDesloc);
end;

procedure TRLTextObject.Inflate(aXFactor, aYFactor: double);
begin
  inherited Inflate(aXFactor,aYFactor);
  //
  fOrigin.X :=Round(fOrigin.X*aXFactor);
  fOrigin.Y :=Round(fOrigin.Y*aYFactor);
  fFont.Size:=Round(fFont.Size*aYFactor);
end;

procedure TRLTextObject.SetBrush(Value:TRLMetaBrush);
begin
  fBrush.Assign(Value);
end;

procedure TRLTextObject.SetFont(Value:TRLMetaFont);
begin
  fFont.Assign(Value);
end;

function TRLTextObject.GetDisplayText:AnsiString;
var s: String;
begin
  s:=String(fText);
  TranslateMacros(s);
  Result:=AnsiString(s);
end;

{ TRLFillRectObject }

constructor TRLFillRectObject.Create(aSurface:TRLGraphicSurface);
begin
  fBrush:=nil;
  //
  fBrush:=TRLMetaBrush.Create(Self);
  //
  inherited;
end;

destructor TRLFillRectObject.Destroy;
begin
  inherited;
  //
  if Assigned(fBrush) then
    fBrush.free;
end;

procedure TRLFillRectObject.SaveToStream(aStream: TStream);
begin
  inherited;
  //
  fBrush.SaveToStream(aStream);
end;

procedure TRLFillRectObject.LoadFromStream(aStream: TStream);
begin
  inherited;
  //
  fBrush.LoadFromStream(aStream);
end;

procedure TRLFillRectObject.PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer);
var
  r:TRect;
begin
  r.Left  :=aXDesloc+Round(fBoundsRect.Left  *aXFactor);
  r.Top   :=aYDesloc+Round(fBoundsRect.Top   *aYFactor);
  r.Right :=aXDesloc+Round(fBoundsRect.Right *aXFactor);
  r.Bottom:=aYDesloc+Round(fBoundsRect.Bottom*aYFactor);
  //
  FromMetaBrush(fBrush,aCanvas.Brush);
  aCanvas.FillRect(r);
end;

procedure TRLFillRectObject.Assign(aObject: TRLGraphicObject); 
begin
  inherited Assign(aObject);
  //
  Brush:=TRLFillRectObject(aObject).Brush;
end;

procedure TRLFillRectObject.SetBrush(Value:TRLMetaBrush);
begin
  fBrush.Assign(Value);
end;

{ TRLEllipseObject }

constructor TRLEllipseObject.Create(aSurface:TRLGraphicSurface);
begin
  fPen  :=nil;
  fBrush:=nil;
  //
  fPen  :=TRLMetaPen.Create(Self);
  fBrush:=TRLMetaBrush.Create(Self);
  //
  inherited;
end;

destructor TRLEllipseObject.Destroy;
begin
  inherited;
  //
  if Assigned(fPen) then
    fPen.free;
  if Assigned(fBrush) then
    fBrush.free;
end;

procedure TRLEllipseObject.SaveToStream(aStream: TStream);
begin
  inherited;
  //
  fPen.SaveToStream(aStream);
  fBrush.SaveToStream(aStream);
end;

procedure TRLEllipseObject.LoadFromStream(aStream: TStream);
begin
  inherited;
  //
  fPen.LoadFromStream(aStream);
  fBrush.LoadFromStream(aStream);
end;

procedure TRLEllipseObject.PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer);
var
  r:TRect;
begin
  r.Left  :=aXDesloc+Round(fBoundsRect.Left  *aXFactor);
  r.Top   :=aYDesloc+Round(fBoundsRect.Top   *aYFactor);
  r.Right :=aXDesloc+Round(fBoundsRect.Right *aXFactor);
  r.Bottom:=aYDesloc+Round(fBoundsRect.Bottom*aYFactor);
  //
  FromMetaPen(fPen,aCanvas.Pen);
  PenInflate(aCanvas.Pen,aXFactor);
  FromMetaBrush(fBrush,aCanvas.Brush);
  aCanvas.Ellipse(r);
end;

procedure TRLEllipseObject.Assign(aObject: TRLGraphicObject); 
begin
  inherited Assign(aObject);
  //
  Pen  :=TRLEllipseObject(aObject).Pen;
  Brush:=TRLEllipseObject(aObject).Brush;
end;

procedure TRLEllipseObject.Inflate(aXFactor, aYFactor: double);
begin
  inherited Inflate(aXFactor,aYFactor);
  //
  fPen.Inflate(aXFactor);
end;

procedure TRLEllipseObject.SetPen(Value:TRLMetaPen);
begin
  fPen.Assign(Value);
end;

procedure TRLEllipseObject.SetBrush(Value:TRLMetaBrush);
begin
  fBrush.Assign(Value);
end;

{ TRLPolygonObject }

constructor TRLPolygonObject.Create(aSurface:TRLGraphicSurface);
begin
  fPen  :=nil;
  fBrush:=nil;
  SetLength(fPoints,0);
  //
  fPen  :=TRLMetaPen.Create(Self);
  fBrush:=TRLMetaBrush.Create(Self);
  //
  inherited;
end;

destructor TRLPolygonObject.Destroy;
begin
  inherited;
  //
  if Assigned(fPen) then
    fPen.free;
  if Assigned(fBrush) then
    fBrush.free;
end;

procedure TRLPolygonObject.SaveToStream(aStream: TStream);
var
  i,count:integer;
begin
  inherited;
  //
  fPen.SaveToStream(aStream);
  fBrush.SaveToStream(aStream);
  count:=High(fPoints)+1;
  aStream.Write(count,SizeOf(count));
  for i:=0 to count-1 do
    aStream.Write(fPoints[i],SizeOf(fPoints[i]));
end;

procedure TRLPolygonObject.LoadFromStream(aStream: TStream);
var
  i,count:integer;
begin
  inherited;
  //
  fPen.LoadFromStream(aStream);
  fBrush.LoadFromStream(aStream);
  aStream.Read(count,SizeOf(count));
  SetLength(fPoints,count);
  for i:=0 to count-1 do
    aStream.Read(fPoints[i],SizeOf(fPoints[i]));
end;

procedure TRLPolygonObject.PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer);
var
  p:TPointArray;
  i:integer;
begin
  SetLength(p,High(fPoints)+1);
  for i:=0 to High(p) do
  begin
    p[i].X:=aXDesloc+Round(fPoints[i].X*aXFactor);
    p[i].Y:=aYDesloc+Round(fPoints[i].Y*aYFactor);
  end;
  //  
  FromMetaPen(fPen,aCanvas.Pen);
  PenInflate(aCanvas.Pen,aXFactor);
  FromMetaBrush(fBrush,aCanvas.Brush);
  aCanvas.Polygon(p);
end;

procedure TRLPolygonObject.Assign(aObject: TRLGraphicObject); 
begin
  inherited Assign(aObject);
  //
  Pen   :=TRLPolygonObject(aObject).Pen;
  Brush :=TRLPolygonObject(aObject).Brush;
  Points:=TRLPolygonObject(aObject).Points;
end;

procedure TRLPolygonObject.Offset(aXDesloc,aYDesloc: integer);
var
  i:integer;
begin
  inherited Offset(aXDesloc,aYDesloc);
  //
  for i:=0 to High(fPoints) do
  begin
    Inc(fPoints[i].X,aXDesloc);
    Inc(fPoints[i].Y,aYDesloc);
  end;
end;

procedure TRLPolygonObject.Inflate(aXFactor, aYFactor: double);
var
  i:integer;
begin
  inherited Inflate(aXFactor,aYFactor);
  //
  for i:=0 to High(fPoints) do
  begin
    fPoints[i].X:=Round(fPoints[i].X*aXFactor);
    fPoints[i].Y:=Round(fPoints[i].Y*aYFactor);
  end;
  fPen.Inflate(aXFactor);
end;

procedure TRLPolygonObject.SetPen(Value:TRLMetaPen);
begin
  fPen.Assign(Value);
end;

procedure TRLPolygonObject.SetBrush(Value:TRLMetaBrush);
begin
  fBrush.Assign(Value);
end;

{ TRLPolylineObject }

constructor TRLPolylineObject.Create(aSurface:TRLGraphicSurface);
begin
  fPen:=nil;
  SetLength(fPoints,0);
  //
  fPen:=TRLMetaPen.Create(Self);
  //
  inherited;
end;

destructor TRLPolylineObject.Destroy;
begin
  inherited;
  //
  if Assigned(fPen) then
    fPen.free;
end;

procedure TRLPolylineObject.SaveToStream(aStream: TStream);
var
  i,count:integer;
begin
  inherited;
  //
  fPen.SaveToStream(aStream);
  count:=High(fPoints)+1;
  aStream.Write(count,SizeOf(count));
  for i:=0 to count-1 do
    aStream.Write(fPoints[i],SizeOf(fPoints[i]));
end;

procedure TRLPolylineObject.LoadFromStream(aStream: TStream);
var
  i,count:integer;
begin
  inherited;
  //
  fPen.LoadFromStream(aStream);
  aStream.Read(count,SizeOf(count));
  SetLength(fPoints,count);
  for i:=0 to count-1 do
    aStream.Read(fPoints[i],SizeOf(fPoints[i]));
end;

procedure TRLPolylineObject.PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer);
var
  p:TPointArray;
  i:integer;
begin
  SetLength(p,High(fPoints)+1);
  for i:=0 to High(p) do
  begin
    p[i].X:=aXDesloc+Round(fPoints[i].X*aXFactor);
    p[i].Y:=aYDesloc+Round(fPoints[i].Y*aYFactor);
  end;
  //
  FromMetaPen(fPen,aCanvas.Pen);
  PenInflate(aCanvas.Pen,aXFactor);
  aCanvas.Brush.Style:=bsClear;
  aCanvas.Polyline(p);
end;

procedure TRLPolylineObject.Assign(aObject: TRLGraphicObject); 
begin
  inherited Assign(aObject);
  //
  Pen   :=TRLPolylineObject(aObject).Pen;
  Points:=TRLPolylineObject(aObject).Points;
end;

procedure TRLPolylineObject.Offset(aXDesloc,aYDesloc: integer);
var
  i:integer;
begin
  inherited Offset(aXDesloc,aYDesloc);
  //
  for i:=0 to High(fPoints) do
  begin
    Inc(fPoints[i].X,aXDesloc);
    Inc(fPoints[i].Y,aYDesloc);
  end;
end;

procedure TRLPolylineObject.Inflate(aXFactor,aYFactor:double);
var
  i:integer;
begin
  inherited Inflate(aXFactor,aYFactor);
  //
  for i:=0 to High(fPoints) do
  begin
    fPoints[i].X:=Round(fPoints[i].X*aXFactor);
    fPoints[i].Y:=Round(fPoints[i].Y*aYFactor);
  end;
  fPen.Inflate(aXFactor);
end;

procedure TRLPolylineObject.SetPen(Value:TRLMetaPen);
begin
  fPen.Assign(Value);
end;

{ TRLImageObject }

constructor TRLImageObject.Create(aSurface:TRLGraphicSurface);
begin
  fData  :='';
  fParity:=false;
  //
  inherited;
end;

procedure TRLImageObject.SaveToStream(aStream: TStream);
var
  len:integer;
begin
  inherited;
  //
  len:=Length(fData);
  aStream.Write(len,SizeOf(len));
  if len>0 then
    aStream.Write(fData[1],len);
  //
  aStream.Write(fParity,SizeOf(fParity));
end;

procedure TRLImageObject.LoadFromStream(aStream: TStream);
var
  len:integer;
begin
  inherited;
  //
  aStream.Read(len,SizeOf(len));
  SetLength(fData,len);
  if len>0 then
    aStream.Read(fData[1],len);
  //
  aStream.Read(fParity,SizeOf(fParity));
end;

procedure TRLImageObject.PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer);
var
  r:TRect;
begin
  r.Left  :=aXDesloc+Round(fBoundsRect.Left  *aXFactor);
  r.Top   :=aYDesloc+Round(fBoundsRect.Top   *aYFactor);
  r.Right :=aXDesloc+Round(fBoundsRect.Right *aXFactor);
  r.Bottom:=aYDesloc+Round(fBoundsRect.Bottom*aYFactor);
  //
  CanvasStretchDraw(aCanvas,r,Data,Parity);
end;

procedure TRLImageObject.Assign(aObject: TRLGraphicObject);
begin
  inherited Assign(aObject);
  //
  Data  :=TRLImageObject(aObject).Data;
  Parity:=TRLImageObject(aObject).Parity;
end;

{ TRLSetClipRectObject }

procedure TRLSetClipRectObject.PaintTo(aCanvas:TCanvas; aXFactor,aYFactor:double; aXDesloc,aYDesloc:integer);
begin
  fSurface.PushClipRect(fSurface.fClipRect);
  fSurface.fClipRect.Left  :=aXDesloc+Round(fBoundsRect.Left  *aXFactor);
  fSurface.fClipRect.Top   :=aYDesloc+Round(fBoundsRect.Top   *aYFactor);
  fSurface.fClipRect.Right :=aXDesloc+Round(fBoundsRect.Right *aXFactor);
  fSurface.fClipRect.Bottom:=aYDesloc+Round(fBoundsRect.Bottom*aYFactor);
  CanvasSetClipRect(aCanvas,fSurface.fClipRect);
end;

{ TRLResetClipRectObject }

procedure TRLResetClipRectObject.PaintTo(aCanvas: TCanvas; aXFactor, aYFactor: double; aXDesloc, aYDesloc: integer);
begin
  fSurface.PopClipRect(fSurface.fClipRect);
  CanvasSetClipRect(aCanvas,fSurface.fClipRect);
end;

end.

