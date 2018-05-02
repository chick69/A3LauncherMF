object fGetPassword: TfGetPassword
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSizeToolWin
  Caption = 'Entrer le mot de passe'
  ClientHeight = 110
  ClientWidth = 365
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 26
    Width = 78
    Height = 15
    Caption = 'Mot de passe'
    Font.Charset = ANSI_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Cambria'
    Font.Style = [fsBold]
    ParentFont = False
  end
  object MDP: TMaskEdit
    Left = 127
    Top = 23
    Width = 187
    Height = 21
    PasswordChar = '*'
    TabOrder = 0
    Text = ''
  end
  object Panel1: TPanel
    Left = 0
    Top = 69
    Width = 365
    Height = 41
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitLeft = 8
    ExplicitTop = 104
    ExplicitWidth = 185
    object Button1: TButton
      Left = 272
      Top = 8
      Width = 75
      Height = 25
      Caption = 'Validation'
      TabOrder = 0
      OnClick = Button1Click
    end
  end
end
