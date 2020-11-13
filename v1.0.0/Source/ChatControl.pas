unit ChatControl;

{$ifdef fpc}
  {$H+}
  {.$mode objfpc}
  {$mode delphi}
{$endif}

interface

//Exemple of Declaration
//function DrawText(hDC: HDC; lpString: LPCWSTR; nCount: Integer;
//  var lpRect: TRect; uFormat: UINT): Integer; external user32 name 'DrawTextW';

//Nativa na D2d1.dll

//void DrawBitmap(
//  ID2D1Bitmap                    *bitmap,
//  const D2D1_RECT_F &            destinationRectangle,
//  FLOAT                          opacity,
//  D2D1_BITMAP_INTERPOLATION_MODE interpolationMode,
//  const D2D1_RECT_F &            sourceRectangle
//);

uses
  {$ifdef fpc}
  LResources,
    {$ifdef windows} //FPC on WINDOWS
       Windows, //{$ifdef fpc}SCROLLINFO{$else}TScrollInfo{$endif}
    {$else}
      //It is necessary to find an equivalent unit for other platforms
      //{$ifdef fpc}SCROLLINFO{$else}TScrollInfo{$endif}
    {$endif}
    Messages, SysUtils, Classes,
    Controls, Graphics, ComCtrls, StdCtrls, LCLType
  {$else} //DELPHI
    WinApi.Windows, WinApi.Messages, System.SysUtils, System.Classes,
    Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls,
    System.StrUtils,   //Uso do Rec
    Vcl.Imaging.pngimage,
    Vcl.ExtCtrls,
    Generics.Collections  //TImage
  {$endif};
type
  TUser = (User1 = 0, User2 = 1);

  TChatTypes = (ctPrivate = 0, ctRegularGroup = 1, ctSuperGroup = 2, ctChanel = 3);

  TMediaType = (mtTexto = 0, mtVideo = 1, mtAudio = 2, mtLink = 3, mtImagem = 4, mtDocumento = 5);

  TMessageInfo = class(TObject)
  private
    FUser: TUser;
    FID: Int64;
    FChatID: Int64;
    FUserName: String;
    FFirstName: String;
    FLastName: String;
    FPhoneNumber: String;
    FMessage: String;
    FMessages: TObjectList<TMessageInfo>;
    FMediaType: TMediaType;
    FFileToSend: TGraphic;
  public
    constructor Create; overload;
    destructor Destroy;
    property User: TUser read FUser write FUser;
    property MessageID: Int64 read FID write FID;
    property ChatID: Int64 read FChatID write FChatID;
    property UserName: String read FUserName write FUserName;
    property FirstName: String read FFirstName write FFirstName;
    property LastName: String read FLastName write FLastName;
    property PhoneNumber: String read FPhoneNumber write FPhoneNumber;
    property &Message: String read FMessage write FMessage;
    property MediaType: TMediaType read FMediaType write FMediaType;
    property FileToSend: TGraphic  read FFileToSend write FFileToSend;
    property Messages: TObjectList<TMessageInfo> read FMessages write FMessages;
  end;

  TInjectChatControl = class(TCustomControl)
  private
    FColor1, FColor2: TColor;
    FStrings: TStringList;
    FStringsAdded: TStringList;
    FTitle: TLabel;  //Add for Test use Title of message(Beta)
    FScrollPos: integer;
    FOldScrollPos: integer;
    FBottomPos: integer;
    FBoxTops: array of integer;
    FInvalidateCache: boolean;
    FColorTitle: TColor;
    FChatType: TChatTypes;
    FMessageInfo: TMessageInfo;
    procedure StringsChanged(Sender: TObject);
    procedure SetColor1(Color1: TColor);
    procedure SetColor2(Color2: TColor);
    procedure SetStringList(Strings: TStringList);
    procedure ScrollPosUpdated;
    procedure InvalidateCache;
    procedure SetColorTitle(const Value: TColor);
    function LoadImage(imgResName: String): TGraphic;
    function DrawSpeechBox(RefRect: TRect; User: TUser): TRect;

  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function SayFile(const MessageInfo: TMessageInfo; ChatType: TChatTypes;
      const Title, S: String; FileStrem: TStream): Integer;
    function Say(const MessageInfo: TMessageInfo{User: TUser}; ChatType: TChatTypes; const Title, S: String): Integer;
    function SayUser(const User: TUser; ChatType: TChatTypes; const Title, S: String): Integer;
    procedure ScrollToBottom;
    {$ifdef fpc}
    property Canvas;
    {$endif}
  published
    property Align;
    property Anchors;
    {$ifndef fpc}
      property BevelEdges;
      property BevelInner;
      property BevelKind default bkNone;
      property BevelOuter;
      property Ctl3D;
      property ImeMode;
      property ImeName;
      property ParentCtl3D;
      property Touch;
      property StyleElements;
      property StyleName;
    {$endif}
    property BiDiMode;
    property Color;
    property ColorTitle: TColor read FColorTitle write SetColorTitle default clBlue;
    property Color1: TColor read FColor1 write SetColor1 default clSkyBlue;
    property Color2: TColor read FColor2 write SetColor2 default clMoneyGreen;
    property Constraints;
    property Strings: TStringList read FStrings write SetStringList;
    {$ifdef fpc}
      property ControlStyle;
    {$endif}
    property DoubleBuffered;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentDoubleBuffered;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    {$ifndef fpc}
      property OnGesture;
      property OnMouseActivate;
    {$endif}
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;

implementation

uses Math;

procedure Register;
begin
  {$ifdef fpc}
    {$I TInjectChatControl.lrs}
  {$endif}
  RegisterComponents('InjectTelegram', [TInjectChatControl]);
end;

{ TInjectChatControl }

procedure TInjectChatControl.Click;
begin
  inherited;
  if CanFocus and TabStop then
    SetFocus;
end;

function TInjectChatControl.DrawSpeechBox(RefRect: TRect; User: TUser) : TRect;
var
  X, Y, W, H, S: Integer;
  Arrow: Array [0..10] Of TPoint; //era 2
  ArrowHeight, ArrowWidth: Integer;
  APaddingTop, APaddingBottom, APaddingLeft, APaddingRight : Integer;

  AMarginY, AMarginX: Integer;
begin
  AMarginY := 7;
  AMarginX := AMarginY + 4;

  APaddingTop := 4;
  APaddingBottom := 4;
  APaddingLeft := 4;
  APaddingRight := 4;

  ArrowHeight := 20;
  ArrowWidth  := 20;

  with Canvas do
  begin
    Pen := Self.Canvas.Pen;
    Brush := Self.Canvas.Brush;
    X := Pen.Width div 2;
    Y := X;
    W := RefRect.Width - Pen.Width + 1; //Width - Pen.Width + 1;
    H := RefRect.Height - ( Pen.Width + 2 );//Height - ( Pen.Width + 8 );

    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;

    if W < H then
      S := W
    else
      S := H;

    If User = User1 then
    Begin                     //Result.Location.X
      //Define a Ponta de seta para a esquerda ---OK---                       //AMarginY = 7
      Arrow[0] := Point(6,  Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 34);
      Arrow[1] := Point(8,  Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 33);
      Arrow[2] := Point(10, Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 32);
      Arrow[3] := Point(13, Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 31);
      Arrow[4] := Point(16, Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 30);
      Arrow[5] := Point(19, Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 29);
      Arrow[6] := Point(22, Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 28);
      Arrow[7] := Point(24, Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 27);
      Arrow[8] := Point(26, Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 26);
      Arrow[9] := Point(26, Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 34);
      Arrow[10] := Point(6, Result.Location.Y  + Result.Height - ArrowHeight - AMarginY + 34);
    End Else
    Begin
      //Define a Ponta de seta para a direita  ---OK---             //AMarginX = 7 + 4
      Arrow[0]  := Point(Result.Location.X + ArrowHeight + AMarginX + 48,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 34);
      Arrow[1]  := Point(Result.Location.X + ArrowHeight + AMarginX + 43,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 33);
      Arrow[2]  := Point(Result.Location.X + ArrowHeight + AMarginX + 39,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 32);
      Arrow[3]  := Point(Result.Location.X + ArrowHeight + AMarginX + 36,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 31);
      Arrow[4]  := Point(Result.Location.X + ArrowHeight + AMarginX + 33,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 30);
      Arrow[5]  := Point(Result.Location.X + ArrowHeight + AMarginX + 30,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 29);
      Arrow[6]  := Point(Result.Location.X + ArrowHeight + AMarginX + 28,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 28);
      Arrow[7]  := Point(Result.Location.X + ArrowHeight + AMarginX + 27,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 27);
      Arrow[8]  := Point(Result.Location.X + ArrowHeight + AMarginX + 26,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 26);
      Arrow[9]  := Point(Result.Location.X + ArrowHeight + AMarginX + 26,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 34);
      Arrow[10] := Point(Result.Location.X + ArrowHeight + AMarginX + 48,
        RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX + 34);
    End;

    //Desenha a Seta
    Polygon(Arrow);

    //Desenha o Retangulo
    RoundRect(
       RefRect.Left - APaddingLeft,
       RefRect.Top - APaddingTop,
       (RefRect.Right + APaddingRight),
       (RefRect.Bottom + APaddingBottom),
       S div 4, S div 4);

    //Define o Tamanho da Area
    result := Rect(
      RefRect.Left - APaddingLeft ,
      RefRect.Top - APaddingTop,
      RefRect.Right + APaddingRight,
      RefRect.Bottom + APaddingBottom);

  end;
end;

constructor TInjectChatControl.Create(AOwner: TComponent);
begin
  inherited;

  {$ifdef fpc}
    ControlStyle := [csOpaque];
    Width := 400;
    Height:= 200;
    Canvas.Brush.Color := Color;
  {$endif}

  DoubleBuffered := true;

  FScrollPos := 0;
  FBoxTops := nil;
  InvalidateCache;

  FStrings := TStringList.Create;

  FStringsAdded := TStringList.Create;  //Para teste

  FTitle := TLabel.Create(Nil);
  FStrings.OnChange := StringsChanged;
  FColor1 := clWhite;
  FColor2 := $00FDF6E0;
  Color := $00E3C578;

  Font.Size := 10;

  FOldScrollPos := MaxInt;
end;

procedure TInjectChatControl.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_VSCROLL;
end;

destructor TInjectChatControl.Destroy;
begin
  FStrings.Free;
  inherited;
end;

function TInjectChatControl.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
  MousePos: TPoint): Boolean;
begin
  dec(FScrollPos, WheelDelta);
  ScrollPosUpdated;
end;

procedure TInjectChatControl.InvalidateCache;
begin
  FInvalidateCache := true;
end;

function TInjectChatControl.LoadImage(imgResName:String): TGraphic;
var
  BMP: TBitmap;
begin
  BMP := TBitmap.Create;
  BMP.LoadFromResourceName(HInstance, imgResName);
  result := BMP;
 // BMP.Free;
End;

procedure TInjectChatControl.Paint;
const
  Aligns: array[TUser] of integer = (DT_RIGHT, DT_LEFT);
var
  Colors: array[TUser] of TColor;
  J: Integer;
var
  User: TUser;
  i, y, MaxWidth, RectWidth: integer;
  r, r2: TRect;
  SI: {$ifdef fpc}SCROLLINFO{$else}TScrollInfo{$endif};
  sHora, TextBreak, LineBreak: String;
  MyMessageInfo: TMessageInfo;
  AMargin: integer;
begin

  inherited;

  Colors[User1] := FColor1;
  Colors[User2] := FColor2;

  AMargin := 18; //Aplicado para left e right

  y := 10 - FScrollPos;
  MaxWidth := ClientWidth div 2;

  Canvas.Font.Assign(Font);

  if FInvalidateCache then
    SetLength(FBoxTops, FStrings.Count); //Seta o tamanho do ScollBox

    //Novo Metodo para controlar as mensagens
//  for MyMessageInfo in FMessageInfo.Messages do
//  Begin
//
//
//  End;


  for i := 0 to FStrings.Count - 1 do
  begin
    //Se ja não estiver impresso não faça nada
//    if Not FStrings.Text.Contains(TMessageInfo(FStrings.Objects[i]).MessageID.ToString) then
//    Begin

      if FInvalidateCache then
        FBoxTops[i] := y + FScrollPos
      else
      begin
        if (i < (FStrings.Count - 1)) and (FBoxTops[i + 1] - FScrollPos < 0) then
          Continue;
        if FBoxTops[i] - FScrollPos > ClientHeight then
          Break;
        y := FBoxTops[i] - FScrollPos;
      end;

               //TUser(FStrings.Objects[i]);
      User :=  TUser(FStrings.Objects[i]); //TMessageInfo(FStrings.Objects[i]).User;

      //Padrões iniciais
      Canvas.Brush.Color := Colors[User];
      Canvas.Pen.Width := 0;
      Canvas.Pen.Color := Colors[User];
                //10..20
      //Define a Posição da Caixa de Texto
      r := Rect(AMargin, y, MaxWidth, 16);

      //Quebra de linha automatica com 40 caracteres
      TextBreak := WrapText(FStrings[i], 40);

      //Recebendo a hora atual
      sHora := FormatDateTime('HH:MM',Time);

      if FChatType = ctPrivate then
      Begin
        FTiTle.Caption := '';
        LineBreak := '';
      End Else
        LineBreak := #13;

      //Define o tamanho da caixa
      DrawText(Canvas.Handle,
        PChar(FTiTle.Caption+LineBreak+TextBreak+#13+sHora+ LoadImage('FLido').ToString),
        Length(FTiTle.Caption+LineBreak+TextBreak+#13+sHora+ LoadImage('FLido').ToString),
        r,
        DT_WORDBREAK or DT_CALCRECT OR DT_LEFT);

      //Seta a direção do texto de acordo com o usuario
      if User = User2 then
      begin
        RectWidth := r.Right - r.Left;
        r.Right := ClientWidth - AMargin;
        r.Left := r.Right - RectWidth;
      end;

      //Define e desenha a Caixa de Mensagem
      r2 := DrawSpeechBox(r, User);

      //Configura o Canvas para o Titulo
      Canvas.Font.Color := FColorTitle;
      Canvas.Font.Style := Canvas.Font.Style + [fsBold];

      //Escreve titulo na tela
      DrawText(Canvas.Handle,
        PChar(FTiTle.Caption),
        Length(FTiTle.Caption),
        r,
        DT_WORDBREAK OR DT_LEFT);

      //Configura o Canvas para o Texto
      Canvas.Font.Color := clBlack;
      Canvas.Font.Style := [];

      //Escreve o Texto na tela
      DrawText(Canvas.Handle,
        PChar(#13+TextBreak),
        Length(#13+TextBreak),
        r,
        DT_WORDBREAK OR DT_LEFT);

      //Configura o Canvas para a Hora
      Canvas.Font.Size := 7;
      Canvas.Font.Color := clGray;
      Canvas.Font.Style := [];

      //Escreve a hora na tela
      DrawText(Canvas.Handle,
        PChar(#13+sHora),
        Length(#13+sHora+LoadImage('FLido').ToString),
        r,
        DT_RIGHT OR DT_BOTTOM OR DT_SINGLELINE);

      { TODO 5 -oDiego -cImagem : Substituir aimagem por uma PNG sem fundo }
     //Carregar Tick de confirmação de entrega e leitura
      Canvas.Draw(r2.Location.X+r2.Width - 24, r2.Location.Y+r2.Height - 18, LoadImage('FLido'));

      case FMessageInfo.MediaType of
        mtTexto: ;
        mtVideo: ;
        mtAudio: ;
        mtLink: ;
        mtImagem:
        Begin
       // if Assigned(FMessageInfo.FileToSend) then
         // Canvas.Draw(r2.Location.X+r2.Width - 24, r2.Location.Y+r2.Height - 18, FMessageInfo.FileToSend);
        End;
        mtDocumento: ;
      end;

      if FInvalidateCache then
      begin
        y := r.Bottom + 10;
        FBottomPos := y + FScrollPos;
      end;
    //End;

  end;

  SI.cbSize := sizeof(SI);
  SI.fMask := SIF_ALL;
  SI.nMin := 0;
  SI.nMax := FBottomPos;
  SI.nPage := ClientHeight;
  SI.nPos := FScrollPos;
  SI.nTrackPos := SI.nPos;

  SetScrollInfo(Handle, SB_VERT, SI, true);

  if FInvalidateCache then
    ScrollToBottom;

  FInvalidateCache := false;

end;

procedure TInjectChatControl.Resize;
begin
  inherited;
  InvalidateCache;
  Invalidate;
end;

function TInjectChatControl.SayFile(const MessageInfo: TMessageInfo; ChatType: TChatTypes; const Title, S: String; FileStrem: TStream): Integer;
begin
//  FileStrem := ;
  result := Say(MessageInfo, ChatType, Title, S);
end;

function TInjectChatControl.Say(const MessageInfo: TMessageInfo{User: TUser}; ChatType: TChatTypes; const Title, S: String): Integer;
begin
  FTitle.Caption := Title;
  FMessageInfo := MessageInfo;
  FChatType := ChatType;
  ControlStyle := [csOpaque];
  //Emdesenvolvimento para controle das mensagens
  FMessageInfo.Messages.Add(MessageInfo);
  result := FStrings.AddObject(S, TObject(FMessageInfo));
end;

function TInjectChatControl.SayUser(const User: TUser; ChatType: TChatTypes; const Title, S: String): Integer;
begin
  FTitle.Caption := Title;
  FChatType := ChatType;
  FTitle.Caption := Title;
  ControlStyle := [csOpaque];
  result := FStrings.AddObject(S, TObject(User));
end;

procedure TInjectChatControl.ScrollToBottom;
begin
  Perform(WM_VSCROLL, SB_BOTTOM, 0);
end;

procedure TInjectChatControl.SetColor1(Color1: TColor);
begin
  if FColor1 <> Color1 then
  begin
    FColor1 := Color1;
    Invalidate;
  end;
end;

procedure TInjectChatControl.SetColor2(Color2: TColor);
begin
  if FColor2 <> Color2 then
  begin
    FColor2 := Color2;
    Invalidate;
  end;
end;

procedure TInjectChatControl.SetColorTitle(const Value: TColor);
begin
  FColorTitle := Value;
end;

procedure TInjectChatControl.SetStringList(Strings: TStringList);
begin
  FStrings.Assign(Strings);
  InvalidateCache;
  Invalidate;
end;

procedure TInjectChatControl.StringsChanged(Sender: TObject);
begin
  InvalidateCache;
  Invalidate;
end;

procedure TInjectChatControl.WndProc(var Message: TMessage);
var
  SI: {$ifdef fpc}SCROLLINFO{$else}TScrollInfo{$endif};
begin
  inherited;
  case Message.Msg of
    WM_GETDLGCODE:
      Message.Result := Message.Result or DLGC_WANTARROWS;
    WM_KEYDOWN:
      case Message.wParam of
        VK_UP:
          Perform(WM_VSCROLL, SB_LINEUP, 0);
        VK_DOWN:
          Perform(WM_VSCROLL, SB_LINEDOWN, 0);
        VK_PRIOR:
          Perform(WM_VSCROLL, SB_PAGEUP, 0);
        VK_NEXT:
          Perform(WM_VSCROLL, SB_PAGEDOWN, 0);
        VK_HOME:
          Perform(WM_VSCROLL, SB_TOP, 0);
        VK_END:
          Perform(WM_VSCROLL, SB_BOTTOM, 0);
      end;
    WM_VSCROLL:
      begin
        case Message.WParamLo of
          SB_TOP:
            begin
              FScrollPos := 0;
              ScrollPosUpdated;
            end;
          SB_BOTTOM:
            begin
              FScrollPos := FBottomPos - ClientHeight;
              ScrollPosUpdated;
            end;
          SB_LINEUP:
            begin
              dec(FScrollPos);
              ScrollPosUpdated;
            end;
          SB_LINEDOWN:
            begin
              inc(FScrollPos);
              ScrollPosUpdated;
            end;
          SB_PAGEUP:
            begin
              dec(FScrollPos, ClientHeight);
              ScrollPosUpdated;
            end;
          SB_PAGEDOWN:
            begin
              inc(FScrollPos, ClientHeight);
              ScrollPosUpdated;
            end;
          SB_THUMBTRACK:
            begin
              ZeroMemory(@SI, sizeof(SI));
              SI.cbSize := sizeof(SI);
              SI.fMask := SIF_TRACKPOS;
              if GetScrollInfo(Handle, SB_VERT, SI) then
              begin
                FScrollPos := SI.nTrackPos;
                ScrollPosUpdated;
              end;
            end;
        end;
        Message.Result := 0;
      end;
  end;
end;

procedure TInjectChatControl.ScrollPosUpdated;
begin
  FScrollPos := EnsureRange(FScrollPos, 0, FBottomPos - ClientHeight);
  if FOldScrollPos <> FScrollPos then
    Invalidate;
  FOldScrollPos := FScrollPos;
end;

{ TMessageInfo }

constructor TMessageInfo.Create;
begin
  inherited Create;
  FMediaType := mtTexto;
  FMessages := TObjectList<TMessageInfo>.Create;
end;

destructor TMessageInfo.Destroy;
var
  I: Integer;
begin
  for I:= 0 to FMessages.Count -1 do
  Begin
    FMessages[I].Free;
  End;

  FFileToSend.Free;
  inherited;
end;

end.
