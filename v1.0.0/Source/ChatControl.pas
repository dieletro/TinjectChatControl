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
    WinApi.Windows, WinApi.Messages,
    Vcl.Dialogs,
    System.SysUtils, System.Classes,
    Vcl.Controls, Vcl.Graphics, Vcl.StdCtrls,
    System.StrUtils,   //Uso do Rec
    Vcl.Imaging.pngimage,
    Vcl.ExtCtrls,
    Generics.Collections  //TImage
  {$endif};
type
  TUser = (User1 = 0, User2 = 1);

  TChatTypes = (ctPrivate = 0, ctRegularGroup = 1, ctSuperGroup = 2, ctChanel = 3);

  TMediaType = (mtTexto = 0, mtVideo = 1, mtAudio = 2, mtLink = 3, mtImagem = 4, mtDocumento = 5, mtAnimation = 6);

  TChat = class
  private
    FUser: TUser;
    FID: Int64;
    FChatID: Int64;
    FUserName: String;
    FFirstName: String;
    FLastName: String;
    FPhoneNumber: String;
    FMessage: String;
    FMediaType: TMediaType;
    FFileToSend: TGraphic;
    FHora: String;
    FSent: Boolean;
  public
    constructor Create;
    destructor Destroy;
    property User: TUser read FUser write FUser;
    property MessageID: Int64 read FID write FID;
    property ChatID: Int64 read FChatID write FChatID;
    property UserName: String read FUserName write FUserName;
    property FirstName: String read FFirstName write FFirstName;
    property LastName: String read FLastName write FLastName;
    property PhoneNumber: String read FPhoneNumber write FPhoneNumber;
    property &Message: String read FMessage write FMessage;
    property Hora: String read FHora write FHora;

    [DEFAULT(False)]
    property Sent: Boolean read FSent write FSent;
    property MediaType: TMediaType read FMediaType write FMediaType;
    property FileToSend: TGraphic  read FFileToSend write FFileToSend;
  end;

  TInjectChatControl = class(TCustomControl)
  private
    FColor1, FColor2: TColor;
    FStrings: TStringList;
    FTitle: TLabel;  //Add for Test use Title of message(Beta)
    FScrollPos: integer;
    FOldScrollPos: integer;
    FBottomPos: integer;
    FBoxTops: array of integer;
    FInvalidateCache: boolean;
    FColorTitle: TColor;
    FChatType: TChatTypes;
    FChat: TChat;
    FMessages: TObjectList<TChat>;
    procedure StringsChanged(Sender: TObject);
    procedure SetStringList(Strings: TStringList);
    procedure SetColor1(Color1: TColor);
    procedure SetColor2(Color2: TColor);
    procedure ScrollPosUpdated;
    procedure InvalidateCache;
    procedure SetColorTitle(const Value: TColor);
    function LoadImage(imgResName: String): TGraphic;
    function DrawSpeechBox(RefRect: TRect; User: TUser; EnableArrow: Boolean = True): TRect;
    function LoadPNGImage(imgResName: String): TGraphic;

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
    function SayFile(const AChat: TChat; AChatType: TChatTypes): Integer;
    function Say(const AChat: TChat; AChatType: TChatTypes): Integer;
    function SayUser(const User: TUser; ChatType: TChatTypes): Integer;
    procedure ScrollToBottom;
    {$ifdef fpc}
    property Canvas;
    {$endif}

  published
    property Messages: TObjectList<TChat> read FMessages write FMessages;
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

function TInjectChatControl.DrawSpeechBox(RefRect: TRect; User: TUser; EnableArrow: Boolean) : TRect;
var
  X, Y, W, H, S: Integer;
  Arrow: Array [0..10] Of TPoint; //era 2
  ArrowHeight, ArrowWidth, AtualPosY, AtualPosX: Integer;
  APaddingTop, APaddingBottom, APaddingLeft, APaddingRight : Integer;
  AMarginY, AMarginX: Integer;
begin
  AMarginY := 11;
  AMarginX := AMarginY {+ 4};

  ArrowHeight := 20;
  ArrowWidth  := 20;

  APaddingTop     := 4;
  APaddingBottom  := 4;
  APaddingLeft    := 4;
  APaddingRight   := 4;

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
      AtualPosY := RefRect.Location.Y  + RefRect.Height - ArrowHeight - AMarginY;

      Arrow[0]   := Point(6,  AtualPosY + 34);
      Arrow[1]   := Point(8,  AtualPosY + 33);
      Arrow[2]   := Point(10, AtualPosY + 32);
      Arrow[3]   := Point(13, AtualPosY + 31);
      Arrow[4]   := Point(16, AtualPosY + 30);
      Arrow[5]   := Point(19, AtualPosY + 29);
      Arrow[6]   := Point(22, AtualPosY + 28);
      Arrow[7]   := Point(24, AtualPosY + 27);
      Arrow[8]   := Point(26, AtualPosY + 26);
      Arrow[9]   := Point(26, AtualPosY + 34);
      Arrow[10]  := Point(6,  AtualPosY + 34);
    End
      Else
    Begin
      //Define a Ponta de seta para a direita  ---OK---
      AtualPosX := RefRect.Location.X + ArrowHeight + AMarginX - 8;
      AtualPosY := RefRect.Location.Y + RefRect.Height - ArrowWidth - AMarginX;

      Arrow[0]  := Point(AtualPosX + 48, AtualPosY + 34);
      Arrow[1]  := Point(AtualPosX + 43, AtualPosY + 33);
      Arrow[2]  := Point(AtualPosX + 39, AtualPosY + 32);
      Arrow[3]  := Point(AtualPosX + 36, AtualPosY + 31);
      Arrow[4]  := Point(AtualPosX + 33, AtualPosY + 30);
      Arrow[5]  := Point(AtualPosX + 30, AtualPosY + 29);
      Arrow[6]  := Point(AtualPosX + 28, AtualPosY + 28);
      Arrow[7]  := Point(AtualPosX + 27, AtualPosY + 27);
      Arrow[8]  := Point(AtualPosX + 26, AtualPosY + 26);
      Arrow[9]  := Point(AtualPosX + 26, AtualPosY + 34);
      Arrow[10] := Point(AtualPosX + 48, AtualPosY + 34);
    End;

    if EnableArrow then
      Polygon(Arrow); //Desenha a Seta

    //Desenha o Retangulo
    RoundRect(
       RefRect.Left - APaddingLeft,
       RefRect.Top - APaddingTop,
       (RefRect.Right + APaddingRight),
       (RefRect.Bottom + APaddingBottom),
       S div 8, S div 8);

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
    Canvas.Brush.Color := Color;
    Width   := 400;
    Height  := 200;
  {$endif}

  DoubleBuffered := true;

  FScrollPos  := 0;
  FBoxTops    := nil;
  InvalidateCache;

  FMessages := TObjectList<TChat>.Create;

  FStrings := TStringList.Create;
  FStrings.OnChange := StringsChanged;

  FTitle  := TLabel.Create(Nil);

  FColor1 := clWhite;
  FColor2 := $00FDF6E0;
  Color   := $00E3C578;

  Font.Size := 12;

  FOldScrollPos := MaxInt;
end;

procedure TInjectChatControl.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style or WS_VSCROLL;
end;

destructor TInjectChatControl.Destroy;
var
  I: Integer;
begin
  FStrings.Free;
   for I := 0 to FMessages.Count - 1 do
      FMessages[I].Free;
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

function TInjectChatControl.LoadPNGImage(imgResName:String): TGraphic;
var
  PNG: TPngImage;
begin
  Png := TPngImage.Create;
  try
    Png.LoadFromResourceName(HInstance, imgResName);
  finally
    Result := Png;
  end;
End;

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
  MyAChat: TChat;
  AMargin: Integer;
begin

  inherited;
  //Definição das Cores dos Usuarios
  Colors[User1] := FColor1;
  Colors[User2] := FColor2;

  //Aplicado para left e right
  AMargin := 18;

  //Definição da Altura
  y := 10 - FScrollPos;

  //Definição da largura maxima da caixa de mensagem
  MaxWidth := ClientWidth div 2;

 // Canvas.Font.Assign(Font);

  if FInvalidateCache then
    //Seta o tamanho do ScollBox
    SetLength(FBoxTops, FMessages.Count);

  //Novo Metodo para controlar as mensagens
  for I := 0 To FMessages.Count -1 do
  Begin

    if FInvalidateCache then
      FBoxTops[i] := y + FScrollPos
    else
    begin
      if (i < (FMessages.Count - 1)) and (FBoxTops[i + 1] - FScrollPos < 0) then
        Continue;
      if FBoxTops[i] - FScrollPos > ClientHeight then
        Break;
      y := FBoxTops[i] - FScrollPos;
    end;

    //Padrões iniciais
    Canvas.Brush.Color := Colors[User];
    Canvas.Pen.Width := 0;
    Canvas.Pen.Color := Colors[User];

    //Define a Posição da Caixa de Texto
    r := Rect(AMargin, y, MaxWidth, 16);

    if FChatType = ctPrivate then
    Begin
      FTiTle.Caption := '';
      LineBreak := '';
    End Else
      LineBreak := #10;

    //Captura o Usuario para definir a posição da Caixa de Texto
    User :=  FMessages[i].User;

    //Quebra de linha automatica com 40 caracteres
    TextBreak := WrapText(FMessages[i].Message, 40);

    //Recebendo a hora atual
    sHora := FMessages[I].Hora;

    if Assigned(FMessages[I]) then
      case FMessages[I].MediaType of
        mtTexto:  //OK
          Begin
          {$REGION 'mtTexto'}
            //Define o tamanho da caixa de mensagem
            DrawText(Canvas.Handle,
              PChar(FMessages[I].UserName
                +LineBreak
                +TextBreak
                +LineBreak
                +LineBreak
                +sHora+'        '),
              Length(FMessages[I].UserName
                +LineBreak
                +TextBreak
                +LineBreak
                +LineBreak
                +sHora+'        ')+(LoadPNGImage('NLido').Width div 2),
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
            Canvas.Font.Size := 10;
            Canvas.Font.Color := FColorTitle;
            Canvas.Font.Style := Canvas.Font.Style + [fsBold];

            //Escreve titulo na tela
            DrawText(Canvas.Handle,
              PChar(FMessages[I].UserName),
              Length(FMessages[I].UserName),
              r,
               DT_SINGLELINE OR DT_LEFT);

            //Configura o Canvas para o Texto
            Canvas.Font.Size := 10;
            Canvas.Font.Color := clBlack;
            Canvas.Font.Style := [];

            //Escreve o Texto na tela
            DrawText(Canvas.Handle,
              PChar(LineBreak+TextBreak+LineBreak),
              Length(LineBreak+TextBreak+LineBreak),
              r,
              {DT_WORDBREAK OR}
              DT_NOFULLWIDTHCHARBREAK OR
              DT_TABSTOP OR
              DT_HIDEPREFIX OR DT_EDITCONTROL OR DT_LEFT);

            //Configura o Canvas para a Hora
            Canvas.Font.Size := 7;
            Canvas.Font.Color := clGray;
            Canvas.Font.Style := [];

            //Escreve a hora na tela
            DrawText(Canvas.Handle,
              PChar(sHora+'        '),
              Length(sHora+'        '),
              r,
              DT_RIGHT OR DT_BOTTOM OR DT_SINGLELINE);

            //Carregar Tick de confirmação de entrega e leitura
            Canvas.Draw(
              r2.Location.X+r2.Width - 27,
              r2.Location.Y+r2.Height - 20,
              LoadPNGImage('NLido'));

          {$ENDREGION 'mtTexto'}
          End;

        mtVideo:
          Begin
          {$REGION 'mtVideo'}

          {$ENDREGION 'mtVideo'}
          End;

        mtAudio:
          Begin
          {$REGION 'mtAudio'}

          {$ENDREGION 'mtAudio'}
          End;

        mtLink:
          Begin
          {$REGION 'mtLink'}
            //Define o tamanho da caixa de mensagem
            DrawText(Canvas.Handle,
              PChar(FMessages[I].UserName
                +LineBreak
                +TextBreak
                +LineBreak
                +LineBreak
                +sHora+'        '),
              Length(FMessages[I].UserName
                +LineBreak
                +TextBreak
                +LineBreak
                +LineBreak
                +sHora+'        ')+(LoadPNGImage('NLido').Width div 2),
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
            Canvas.Font.Size := 10;
            Canvas.Font.Color := FColorTitle;
            Canvas.Font.Style := Canvas.Font.Style + [fsBold];

            //Escreve titulo na tela
            DrawText(Canvas.Handle,
              PChar(FMessages[I].UserName),
              Length(FMessages[I].UserName),
              r,
               DT_SINGLELINE OR DT_LEFT);

            //Configura o Canvas para o Texto
            Canvas.Font.Size := 10;
            Canvas.Font.Color := $00D0A61A;
            Canvas.Font.Style := Canvas.Font.Style + [fsUnderline];

            //Escreve o Texto na tela
            DrawText(Canvas.Handle,
              PChar(LineBreak
                +TextBreak
                +LineBreak
                +LineBreak
                +LineBreak),
              Length(LineBreak
                +TextBreak
                +LineBreak
                +LineBreak
                +LineBreak),
              r,
              {DT_WORDBREAK OR}
              DT_NOFULLWIDTHCHARBREAK OR
              DT_TABSTOP OR
              DT_HIDEPREFIX OR DT_EDITCONTROL OR DT_LEFT);

            //Configura o Canvas para a Hora
            Canvas.Font.Size := 7;
            Canvas.Font.Color := clGray;
            Canvas.Font.Style := [];

            //Escreve a hora na tela
            DrawText(Canvas.Handle,
              PChar(sHora+'        '),
              Length(sHora+'        '),
              r,
              DT_RIGHT OR DT_BOTTOM OR DT_SINGLELINE);

            //Carregar Tick de confirmação de entrega e leitura
            Canvas.Draw(
              r2.Location.X+r2.Width - 27,
              r2.Location.Y+r2.Height - 20,
              LoadPNGImage('NLido'));
          {$ENDREGION 'mtLink'}
          End;

        mtImagem:
          Begin
          {$REGION 'mtImagem'}

            if Assigned(FMessages[I].FileToSend) then
              //Define o tamanho da caixa
              DrawText(Canvas.Handle,
                PChar(FMessages[I].Message
                +sHora+'        '),
                Length(sHora+'        ')+500
                {FMessages[I].FileToSend.Height},
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
            //r2 := DrawSpeechBox(r, User, False);

            //Configura o Canvas para a Hora
            Canvas.Font.Size := 7;
            Canvas.Font.Color := clGray;
            Canvas.Font.Style := [];

            //Escreve a hora na tela
            DrawText(Canvas.Handle,
              PChar(sHora+'        '),
              Length(sHora+'        '),
              r,
              DT_RIGHT OR DT_BOTTOM OR DT_SINGLELINE);

            Canvas.StretchDraw(r, FMessages[I].FileToSend);

            //Carregar Tick de confirmação de entrega e leitura
            Canvas.Draw(
              r2.Location.X+r2.Width - 27,
              r2.Location.Y+r2.Height - 20,
              LoadPNGImage('NLido'));

          {$ENDREGION 'mtImagem'}
          End;

        mtDocumento:
          Begin
          {$REGION 'mtDocumento'}

          {$ENDREGION 'mtDocumento'}
          End;

        mtAnimation:
          Begin
          {$REGION 'mtAnimation'}
            //DrawAnimatedRects(Canvas.Handle, IDANI_CAPTION,r, r2);
          {$ENDREGION 'mtAnimation'}
          End;
      end;


      if FInvalidateCache then
      begin
        y := r.Bottom + 10;
        FBottomPos := y + FScrollPos;
      end;
    //End;

    FMessages[I].Sent := True;
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

function TInjectChatControl.SayFile(const AChat: TChat; AChatType: TChatTypes): Integer;
begin
//  FileStrem := ;
  Result := Say(AChat, AChatType);
end;

function TInjectChatControl.Say(const AChat: TChat; AChatType: TChatTypes): Integer;
begin
  FChat := AChat;
  FChatType := AChatType;
  ControlStyle := [csOpaque];
  //Em desenvolvimento para controle das mensagens
  Result := FMessages.Add(FChat);
 // Result := FStrings.AddObject(FChat.Message, TObject(FChat));
  InvalidateCache;
  Invalidate;
end;

function TInjectChatControl.SayUser(const User: TUser; ChatType: TChatTypes): Integer;
begin
//  FTitle.Caption := Title;
  FChatType := ChatType;
  ControlStyle := [csOpaque];
//  result := FStrings.AddObject(S, TObject(User));
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

{ TChat }

constructor TChat.Create;
begin
  FMediaType := mtTexto;
end;

destructor TChat.Destroy;
begin
{ TODO 2 -oDiego Lacerda -cMemoryLeak : //Erro Reportado Aqui ao Destruir... }
  if Assigned(FFileToSend) then
    FFileToSend.Free;
end;

end.
