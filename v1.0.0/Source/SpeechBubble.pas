unit SpeechBubble;
{**  A Very basic Speech Bubble component with 2 styles.
   SpeechBox and Think Cloud. It needs a bit of tweaking to get things
   perfect but I think it should be a good starting point for someone
   who needs such a component. I only put it together because I hadn't
   written a component from scratch in a while ( an this probably shows
)
   and someone on the delphi.graphics newsgroup was asking for one. So
this
   was my first attempt.
   All I ask is that if you improve this component in any way ( which
I'm sure
    someone will ) is that you send me a copy of the improved component.
   So it's free to use for what ever purpose you so desire.
   I couldn't work out how to get the component to notice a font change
so if someone
   fixes this, please let me know how you fixed this.
   I'll also be putting this up on my website for download soon.
   Created By : Dominique Louis On : 30/05/1999.
   Send e- mailto:Domini...@SavageSoftware.com.au
   Company : Savage Software Solutions
   WebSite : http://www.SavageSoftware.com.au
   Delphi Games Site : http://www.SavageSoftware.com.au/delphi/
**}
interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
Dialogs,
  ExtCtrls, StdCtrls;
type
  TBubbleShape = ( bsSpeechBox, bsThinkCloud );
  TSpeechBubble = class(TGraphicControl)
  private
    { Private declarations }
    fBrush: TBrush;
    fBubbleShape: TBubbleShape;
    fPen: TPen;
    procedure setBubbleShape(const Value: TBubbleShape);
    function DrawThinkCloud : TRect;
    function DrawSpeechBox : TRect;
    procedure SetBrush(const Value: TBrush);
    procedure SetPen(const Value: TPen);
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
  protected
    { Protected declarations }
    procedure Paint; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    { Published declarations }
    property Align;
    property Anchors;
    procedure StyleChanged(Sender: TObject);
    property Brush: TBrush read FBrush write SetBrush;
    property BubbleShape : TBubbleShape read fBubbleShape write setBubbleShape;
    property Caption;
    property Constraints;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Font;
    property ParentShowHint;
    property Pen: TPen read FPen write SetPen;
    property ShowHint;
    property Visible;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('InjectTelegram', [TSpeechBubble]);
end;

{ TSpeechButton }

procedure TSpeechBubble.CMFontChanged(var Message: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TSpeechBubble.CMTextChanged(var Message: TMessage);
begin
  Invalidate;
end;

constructor TSpeechBubble.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable];
  Width := 180;
  Height := 60;
  fPen := TPen.Create;
  fPen.OnChange := StyleChanged;
  fPen.Style := psClear;
  fBrush := TBrush.Create;
  fBrush.OnChange := StyleChanged;
  fBubbleShape := bsSpeechBox;
end;

destructor TSpeechBubble.Destroy;
begin
  FPen.Free;
  FBrush.Free;
  inherited Destroy;
end;

function TSpeechBubble.DrawSpeechBox : TRect;
var
  X, Y, W, H, S: Integer;
begin
  with Canvas do
  begin
    Pen := fPen;
    Brush := fBrush;
    X := Pen.Width div 2;
    Y := X;
    W := Width - Pen.Width + 1;
    H := Height - ( Pen.Width + 8 ) ;
    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;
    if W < H then S := W else S := H;
    Polygon( [Point(10, Height - 10), Point(0, Height), Point(20, Height
- 10)] );
    RoundRect(X, Y, X + W, Y + H, S div 4, S div 4);
    result := Rect( X , Y, W - 5, H - 10);
  end;
end;

function TSpeechBubble.DrawThinkCloud : TRect;
var
  X, Y, W, H: Integer;
  CloudRect : TRect;
begin
  with Canvas do
  begin
    Pen := fPen;
    Brush := fBrush;
    X := Pen.Width div 2;
    Y := X;
    W := Width - Pen.Width + 1;
    H := Height - ( Pen.Width + 8 );
    if Pen.Width = 0 then
    begin
      Dec(W);
      Dec(H);
    end;
    CloudRect := Rect( X , Y, W div 2 + 10, H div 2 + 10 );
    Ellipse( 0, Height - 5, 5, Height - 10 );
    Ellipse( 5, Height - 10, 15, Height - 15 );
    Ellipse( CloudRect.Left, CloudRect.Top, CloudRect.Right ,
CloudRect.Bottom );
    OffSetRect ( CloudRect, (w div 2) - 10, 0 );
    Ellipse( CloudRect.Left, CloudRect.Top, CloudRect.Right ,
CloudRect.Bottom );
    OffSetRect ( CloudRect, -( (w div 2) - 10), ( H div 2 - 10 ) );
    Ellipse( CloudRect.Left, CloudRect.Top, CloudRect.Right ,
CloudRect.Bottom );
    OffSetRect ( CloudRect, (w div 2)- 10 , -( ( H div 2 ) - 10 ) + ( H
div 2 - 10 ) );
    Ellipse( CloudRect.Left, CloudRect.Top, CloudRect.Right ,
CloudRect.Bottom );
    result := Rect( X , Y, W - 10, H - 10 );
  end;
end;

procedure TSpeechBubble.Paint;
var
  Rect, CalcRect : TRect;
begin
  case fBubbleShape of
    bsThinkCloud :
      Rect := DrawThinkCloud;
    bsSpeechBox :
      Rect := DrawSpeechBox;
  end;
  with Canvas do
  begin
    Font := Font;
    Font.Color := Pen.Color;
    Brush.Style := bsClear;
    CalcRect := Rect;
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), CalcRect, (
DT_WORDBREAK or DT_CENTER or DT_CALCRECT ) );
    OffsetRect(Rect, 0, (Height - CalcRect.Bottom) div 2);
    DrawText(Canvas.Handle, PChar(Caption), Length(Caption), Rect, (
DT_WORDBREAK or DT_CENTER ) );
  end;
end;

procedure TSpeechBubble.SetBrush(const Value: TBrush);
begin
  if fBrush <> Value then
    fBrush.Assign(Value);
end;

procedure TSpeechBubble.setBubbleShape(const Value: TBubbleShape);
begin
  if fBubbleShape <> Value then
  begin
    fBubbleShape := Value;
    Invalidate;
  end;
end;

procedure TSpeechBubble.SetPen(const Value: TPen);
begin
  if fPen <> Value then
    fPen.Assign(Value);
end;

procedure TSpeechBubble.StyleChanged(Sender: TObject);
begin
  Invalidate;
end;

end.
