{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit TInjectChatControl;

{$warn 5023 off : no warning about unused units}
interface

uses
  ChatControl, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ChatControl', @ChatControl.Register);
end;

initialization
  RegisterPackage('TInjectChatControl', @Register);
end.
