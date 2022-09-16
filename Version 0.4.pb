Structure ColorCode
  Color.i
  Type.i
  Name.s
  Endianess.i
  
  Alignment.i
  ;absolut
  Abs_Len.i
  ;relativ
  ReferencePxlName.s
  ReferenceOffset.i
  ReferenceLength.i
  ;Regex
  Regex.s
  Regex_Grp.i
  ;Pointer+Offset
  PointerLength.i
  Offset.i
  ResultLength.i
  Multiply.i
  ;Wertetabelle
  WerteTabelle.s
  
  List StartXe.i()
  List ExtractedInformation.s()
  
EndStructure
Structure pxl
  Name.s
  List Pxl.ColorCode()
EndStructure
Structure hwnd
  Window.i
  Toolbar.i
  Navigation.i
  Menu.i
  Splitter.i
  Editor.i
  ComboBox.i
  MaskTitle.i
EndStructure
Structure CHARFORMAT2_ 
  cbSize.l 
  dwMask.l  
  dwEffects.l  
  yHeight.l  
  yOffset.l  
  crTextColor.l  
  bCharSet.b  
  bPitchAndFamily.b  
  szFaceName.b[#LF_FACESIZE]  
  _wPad2.w  
  wWeight.w  
  sSpacing.w  
  crBackColor.l  
  lcid.l  
  dwReserved.l  
  sStyle.w  
  wKerning.w  
  bUnderlineType.b  
  bAnimation.b  
  bRevAuthor.b  
  bReserved1.b 
EndStructure 
Structure RegexStruc
  Name.s
  Command.s
EndStructure
Structure MultiFileStructure
  Inhalt.s
  Dateinamen.s
EndStructure

;Bugs:
; Absolute Posiiton Beginnt bei 1 nicht bei 0
; relative Bezüge zeigen bei rechtsklick immer auf das gleiche statt das richtige Element
; Bezüge auf Bezüge -> Zirkelbezug wird nicht erkannt
; Bezüge auf Bezüge, Fehlender Initalbezug wird nicht richtig erkannt
; unklar ob bezüge auf bezüge richtig funktionieren
Enumeration 1000
  #Absolut_E_Text
  #Absolut_Len
  #Absolut_S_Text
  #Absolut_Start
  #AlignmentCombo
  #BigEndian
  #ColorPicker
  #ColorPickerImage
  #DeleteMaskField
  #DirLoad
  #EditorPopup
  #Endian_S_T
  #EndianSelector
  #Extrahieren
  #Help
  #Image1
  #Image2
  #Image3
  #Image4
  #Image5
  #Image6
  #Image7
  #Image8
  #Image9
  #Konvertieren
  #Laden
  #LadenI
  #LastFile
  #left
  #LittleEndian
  #MakeAutoMask
  #MaskTitle
  #NeueMaske
  #NewBitstream
  #NewMaskField
  #NextFile
  #NoInterpret
  #Pointer_L_T
  #Pointer_Len
  #Pointer_M_T
  #Pointer_Mul
  #Pointer_O_T
  #Pointer_Off
  #Pointer_R_T
  #Pointer_Res
  #Pointer_S_T
  #Pointer_Start
  #Regex_D_T
  #Regex_Default
  #Regex_Group
  #Regex_I_T
  #Regex_Input
  #Relativ_L_T
  #Relativ_Len
  #Relativ_O_T
  #Relativ_Off
  #Relativ_R_T
  #Relativ_Ref
  #right
  #SpeicherMaske
  #SpeicherMasken
  #SuchenStarten
  #Toolbar_button_4
  #Toolbar_button_5
  #Toolbar_button_6
  #Toolbar_Load
  #Toolbar_Speichern
  #Tree
  #Type_S_T
  #TypeSelector
  #Vergleichen
  #VerReset
  #WerteTabelleB
  #WerteTabelleS
  #WerteTabelleT
  #XML
EndEnumeration

If UsePNGImageDecoder() = 0 ;{
  MessageRequester("Error", "Can't open the image decoder", 0)
  End
EndIf
If InitKeyboard() = 0
  MessageRequester("Error", "Can't open keyboard driver", 0)
  End
EndIf
If UseMD5Fingerprint() = 0
  MessageRequester("Error", "Can't open the MD5-encoder", 0)
  End
EndIf;}

Declare RePaintAll()
Declare UpdateDatenfeld(ID.i)
Declare.l Get_Editor_Zoom()
Declare Set_Editor_Zoom()

Global FileString.s{10000000}
Global XMLMainnode.pxl
Global Handles.hwnd
Global XOR_Result.s
Global InhaltSchonImXORArray.s
Global ZoomParams.POINT

Global NewList Regex.RegexStruc()
Global NewList Spruchkopf.RegexStruc()
Global NewList MultiFiles.MultiFileStructure()
Global NewList PushedKeys.l() 
Global NewList RelativSort.Colorcode()
Global Dim XORData.b(100000,0)

;{ Regex Defaults
AddElement(Regex()) : Regex()\Name = "Base-64"               :Regex()\Command = "[A-Za-z0-9+/]{4}[A-Za-z0-9+/]*"
AddElement(Regex()) : Regex()\Name = "russischer Satz"       :Regex()\Command = "([А-Я]?[а-я][а-я]+(?:[,|:|;|&|\(|\)|\{|\}|\[|\]]?\s(?:\d+|[а-яA-Я]?[а-я]*)){3,}+[\.|\?|\!])"
AddElement(Regex()) : Regex()\Name = "deutscher Satz"        :Regex()\Command = "([A-Z]?[a-zß-ü][a-zß-ü]+(?:[,|:|;|&|\(|\)|\{|\}|\[|\]]?\s(?:\d+|[a-zA-Z]?[a-zß-ü]*)){3,}+[\.|\?|\!])"
AddElement(Regex()) : Regex()\Name = "IP-Adresse"            :Regex()\Command = "((?:\d{1,3}\.){3}\d{1,3})"
AddElement(Regex()) : Regex()\Name = "Emailadresse"          :Regex()\Command = "([a-zA-Z0-9\._%+-]{1,20}@[a-zA-Z0-9]{1,20}(?:\.[a-zA-Z0-9]){0,8}\.(?:[a-z]){2,3})"
AddElement(Regex()) : Regex()\Name = "deutsche Handynummer"  :Regex()\Command = "([0|+49]17[1-8][\/|\\|\-]?\d{6,9})"
AddElement(Regex()) : Regex()\Name = "VISA-Kreditkarte"      :Regex()\Command = "4[0-9]{3}( ?[0-9]{4}){2}(?:[0-9]{3})?"
AddElement(Regex()) : Regex()\Name = "Mastercard-Kreditkarte":Regex()\Command = "(?:5[1-5][0-9]{2}|222[1-9]|22[3-9]|2[3-6][0-9]{2}|27[01][0-9]|2720)[0-9]{12}"
;}

;Editor
Procedure Editor_BackColor(Gadget, Color.l) 
  format.CHARFORMAT2_ 
  format\cbSize = SizeOf(CHARFORMAT2_) 
  format\dwMask = $4000000  ; = #CFM_BACKCOLOR 
  format\crBackColor = Color 
  SendMessage_(GadgetID(Gadget), #EM_SETCHARFORMAT, #SCF_SELECTION, @format)
EndProcedure
Procedure Editor_Select(Gadget, LineStart.l, CharStart.l, LineEnd.l, CharEnd.l)    
  sel.CHARRANGE 
  sel\cpMin = SendMessage_(GadgetID(Gadget), #EM_LINEINDEX, LineStart, 0) + CharStart - 1 
  
  If LineEnd = -1 
    LineEnd = SendMessage_(GadgetID(Gadget), #EM_GETLINECOUNT, 0, 0)-1 
  EndIf 
  sel\cpMax = SendMessage_(GadgetID(Gadget), #EM_LINEINDEX, LineEnd, 0) 
  
  If CharEnd = -1 
    sel\cpMax + SendMessage_(GadgetID(Gadget), #EM_LINELENGTH, sel\cpMax, 0) 
  Else 
    sel\cpMax + CharEnd - 1 
  EndIf 
  SendMessage_(GadgetID(Gadget), #EM_EXSETSEL, 0, @sel) 
EndProcedure 
Procedure.s Editor_Read(Gadget.i,Leng)
  Test.s = Space(Leng)
  SendMessage_(GadgetID(Gadget),#EM_GETSELTEXT, 0, Test)
  ProcedureReturn Test
EndProcedure
Procedure WriteEditor(*FileString,FileSize)
  zoom.l=  Get_Editor_Zoom()
  SetGadgetText(Handles\Editor,ReplaceString(ReplaceString(PeekS(*FileString,FileSize,#PB_Ascii),#CRLF$,#LF$),#TAB$," "))
  Set_Editor_Zoom()
EndProcedure
Procedure Set_Editor_Zoom();TODO
  lRet=SendMessage_(GadgetID(Handles\Editor),#EM_SETZOOM,ZoomParams\x,ZoomParams\y) 
EndProcedure
Procedure.l Get_Editor_Zoom()
  Protected wParam.l, hParam.l, result.l
  result = SendMessage_(GadgetID(Handles\Editor),#EM_GETZOOM,@wParam,@hParam)
  If wParam = 0 And hParam = 0
    ProcedureReturn 100
  Else
    ZoomParams\x = wParam
    ZoomParams\y = hParam
  EndIf
EndProcedure

;GUI
Procedure WinCallback(Win,Msg,wParam,lParam) 
  Select Msg 
    Case #WM_SIZE 
        ResizeGadget(handles\Splitter,0,28,WindowWidth(Handles\Window),#PB_Ignore)
;         ResizeGadget(handles\Editor,0,0,WindowWidth(Handles\Window)-GadgetWidth(handles\Splitter),#PB_Ignore)
;        SetGadgetState(handles\Splitter,WindowWidth(Handles\Window)-300)
;       ResizeGadget(#tree, -5, 210, 300, WindowHeight(Handles\Window)-260)
  EndSelect 
  ProcedureReturn #PB_ProcessPureBasicEvents 
EndProcedure 
Procedure GUI()
  Handles\window = OpenWindow(#PB_Any, 50, 50, 1100, 800, "BitMasker von J. S.", #PB_Window_SystemMenu | #PB_Window_MaximizeGadget| #PB_Window_SizeGadget | #PB_Window_ScreenCentered)
  Handles\Editor = EditorGadget(#PB_Any,0,28,WindowWidth(Handles\window)-310,WindowHeight(Handles\window),#PB_Editor_WordWrap)
  
  Handles\Navigation = ContainerGadget(#PB_Any,0,0,100,100);{
  Handles\MaskTitle = TextGadget(#PB_Any,0,5,150,15,"Aktuell keine Maske geladen.")
  StringGadget(#MaskTitle,80,0,150,22,"")
  HideGadget(#MaskTitle,1)
  TextGadget(#PB_Any,0,30,80,25,"Datenfeld:")
  handles\ComboBox = ComboBoxGadget(#PB_Any,80,25,140,25)
  CatchImage(#Image1,?NewMask)
  ButtonImageGadget(#NewMaskField,225,24,25,27,ImageID(#Image1))
  CatchImage(#Image2,?Deletemask)
  ButtonImageGadget(#DeleteMaskField,250,24,25,27,ImageID(#Image2))
  
  TextGadget(#PB_Any,0,60,50,25,"Farbe:")
  CreateImage(#ColorPickerImage,25,27,24,#Yellow)
  ButtonImageGadget(#ColorPicker,40,54,25,27,ImageID(#ColorPickerImage))
  
  TextGadget(#Endian_S_T,180,60,52,25,"Endianess:")
  ComboBoxGadget(#EndianSelector,235,55,50,25)
  AddGadgetItem(#EndianSelector,0,"Big")
  AddGadgetItem(#EndianSelector,1,"Little")
  AddGadgetItem(#EndianSelector,2,"No")
  SetGadgetState(#EndianSelector,2)
  
  TextGadget(#Type_S_T,70,60,20,25,"Typ:")
  ComboBoxGadget(#TypeSelector,95,55,80,25)
  AddGadgetItem(#TypeSelector,0,"Byte")
  AddGadgetItem(#TypeSelector,1,"Word")
  AddGadgetItem(#TypeSelector,2,"Integer")
  AddGadgetItem(#TypeSelector,3,"Quad")
  AddGadgetItem(#TypeSelector,4,"String")
  SetGadgetState(#TypeSelector,2)
  
  TextGadget(#PB_Any,0,90,77,25,"Orientierung:")
  ComboBoxGadget(#AlignmentCombo,125,88,160,25)
  AddGadgetItem(#AlignmentCombo,0,"absolute Position")
  AddGadgetItem(#AlignmentCombo,1,"Regex")
  AddGadgetItem(#AlignmentCombo,2,"Pointer+Offset")
  AddGadgetItem(#AlignmentCombo,3,"Werte-Tabelle")
  AddGadgetItem(#AlignmentCombo,4,"relative Position")
  SetGadgetState(#AlignmentCombo,0)
  
  ;absolut
  TextGadget(#Absolut_S_Text,0,120,80,20,"Start-Position:")
  StringGadget(#Absolut_Start,70,118,40,20,"1")
  TextGadget(#Absolut_E_Text,0,140,80,20,"Länge:")
  StringGadget(#Absolut_Len,70,138,40,20,"1")
  HideGadget(#Absolut_Start ,1)
  HideGadget(#Absolut_Len   ,1)
  HideGadget(#Absolut_S_Text,1)
  HideGadget(#Absolut_E_Text,1)
  
  ;relativ
  TextGadget(#Relativ_R_T,0,120,100,20,"Referenz-Datenfeld:")
  ComboBoxGadget(#Relativ_Ref,100,117,120,22)
  TextGadget(#Relativ_O_T,0,150,100,20,"Referenz-Offset:")
  StringGadget(#Relativ_Off,100,147,30,22,"1",#PB_String_Numeric)
  TextGadget(#Relativ_L_T,140,150,40,20,"Länge:")
  StringGadget(#Relativ_Len,180,147,30,22,"1",#PB_String_Numeric)
  HideGadget(#Relativ_Len,1)
  HideGadget(#Relativ_L_T,1)
  HideGadget(#Relativ_Ref,1)
  HideGadget(#Relativ_Off,1)
  HideGadget(#Relativ_O_T,1)
  HideGadget(#Relativ_R_T,1)
  
  ;Regex
  TextGadget(#Regex_I_T,0,125,100,20,"Regulärer Ausdruck:")
  StringGadget(#Regex_Input,0,147,290,22,".*")
  CheckBoxGadget(#Regex_Group,120,120,90,25,"Nur Gruppen")
  TextGadget(#Regex_D_T,0,180,130,25,"Vorgefertigte Regex:")
  ComboBoxGadget(#Regex_Default,135,175,150,25)
  HideGadget(#Regex_Default,1)
  HideGadget(#Regex_D_T,1)
  HideGadget(#Regex_Group ,1)
  HideGadget(#Regex_Input ,1)
  HideGadget(#Regex_I_T   ,1)
  ForEach Regex()
    AddGadgetItem(#Regex_Default,-1,Regex()\Name)
  Next
  
  ;Pointer+Offset
  TextGadget(#Pointer_S_T,0,125,100,20,"Pointer-Start:")
  TextGadget(#Pointer_L_T,0,155,100,20,"Pointer-Länge:")
  TextGadget(#Pointer_O_T,0,185,100,20,"Offset:")
  TextGadget(#Pointer_R_T,150,125,100,20,"Ziel-Länge:")
  TextGadget(#Pointer_M_T,150,155,100,20,"P-Multiplikator:")
  StringGadget(#Pointer_Mul,250,122,40,22,"8",#PB_String_Numeric)
  StringGadget(#Pointer_Res,250,152,40,22,"50",#PB_String_Numeric)
  StringGadget(#Pointer_Start,100,122,40,22,"50",#PB_String_Numeric)
  StringGadget(#Pointer_Len,100,152,40,22,"50",#PB_String_Numeric)
  StringGadget(#Pointer_Off,100,182,40,22,"50",#PB_String_Numeric)
  HideGadget(#Pointer_M_T,1)
  HideGadget(#Pointer_Mul,1)
  HideGadget(#Pointer_S_T,1)
  HideGadget(#Pointer_L_T,1)
  HideGadget(#Pointer_O_T,1)
  HideGadget(#Pointer_Start,1)
  HideGadget(#Pointer_Len,1)
  HideGadget(#Pointer_Off,1)
  HideGadget(#Pointer_R_T,1)
  HideGadget(#Pointer_Res,1)
  
  ;WerteTabelle
  TextGadget(#WerteTabelleT,0,125,100,20,"WerteTabelle:")
  StringGadget(#WerteTabelleS,70,122,200,22,GetCurrentDirectory())
  ButtonGadget(#WerteTabelleB,270,120,25,25,"...")
  HideGadget(#WerteTabelleT,1)
  HideGadget(#WerteTabelleS,1)
  HideGadget(#WerteTabelleB,1)
  
  TreeGadget(#tree, -5, 210, 300, WindowHeight(Handles\Window)-260)
  
  CloseGadgetList();}
  
  DragAcceptFiles_(WindowID(Handles\window),1)
  
  If Handles\Window
    Handles\Toolbar = CreateToolBar(#PB_Any, WindowID(Handles\window))
    CatchImage(#Image3,?Image3):ToolBarImageButton(#NewBitstream, ImageID(#image3))
    CatchImage(#Image4,?Image4):ToolBarImageButton(#Toolbar_Load, ImageID(#image4))
    CatchImage(#Image5,?Image5):ToolBarImageButton(#Toolbar_Speichern, ImageID(#image5))
    ToolBarSeparator()
    CatchImage(#Image6,?Image6):ToolBarImageButton(#Toolbar_button_4, ImageID(#image6))
    ToolBarToolTip(Handles\Toolbar, #Toolbar_button_4, "Ausschneiden")
    CatchImage(#Image7,?Image7):ToolBarImageButton(#Toolbar_button_5, ImageID(#image7))
    ToolBarToolTip(Handles\Toolbar, #Toolbar_button_5, "Kopieren")
    CatchImage(#Image8,?Image8):ToolBarImageButton(#Toolbar_button_6, ImageID(#image8))
    ToolBarToolTip(Handles\Toolbar, #Toolbar_button_6, "Einfügen")
    ToolBarSeparator()
    DisableToolBarButton(Handles\Toolbar,#Toolbar_button_4,1)
    DisableToolBarButton(Handles\Toolbar,#Toolbar_button_5,1)
    DisableToolBarButton(Handles\Toolbar,#Toolbar_button_6,1)
    CatchImage(#Image9,?Image9):ToolBarImageButton(#SuchenStarten, ImageID(#image9))
    ToolBarToolTip(Handles\Toolbar, #SuchenStarten, "Suche nach Muster")
    ToolBarSeparator()
    CatchImage(#left,?Left):ToolBarImageButton(#LastFile, ImageID(#left))
    ToolBarToolTip(Handles\Toolbar, #LastFile, "Vorherige Datei anzeigen")
    CatchImage(#right,?Right):ToolBarImageButton(#NextFile, ImageID(#right))
    ToolBarToolTip(Handles\Toolbar, #NextFile, "Nächste Datei anzeigen")
    DisableToolBarButton(Handles\Toolbar,#LastFile,1)
    DisableToolBarButton(Handles\Toolbar,#NextFile,1)
  EndIf
  
  SplitterGadget(Handles\Splitter,0,28,WindowWidth(Handles\window),WindowHeight(Handles\window)-50,Handles\Editor,Handles\Navigation,#PB_Splitter_Vertical | #PB_Splitter_SecondFixed )
  
  SetGadgetState(Handles\Splitter,WindowWidth(Handles\window)-300)
  
  If CreateMenu(Handles\Menu, WindowID(Handles\window))
    MenuTitle("Datei")
    MenuItem(#Laden, "Laden")
    MenuItem(#SpeicherMasken, "Speichern")
    MenuItem(#DirLoad, "Verzeichnis laden")
    MenuItem(#Konvertieren, "Verzeichnis in binär wandeln")
    MenuTitle("Maske")
    MenuItem(#NeueMaske, "Neue Maske")
    MenuItem(#LadenI, "Laden")
    MenuItem(#SpeicherMaske, "Speichern")
    MenuTitle("Vergleichen")
    MenuItem(#Vergleichen, "Vergleichen")
    MenuItem(#MakeAutoMask, "Erstelle Maske aus Vergleich")
    MenuItem(#VerReset, "Vergleich - Reset")
    MenuTitle("Information")
    MenuItem(#Extrahieren, "Extrahieren")
    MenuTitle("Hilfe")
    MenuItem(#Help,"Regex-Hilfe")
  EndIf
  
  DisableToolBarButton(Handles\Toolbar, #Toolbar_Speichern, 1) ; Disable the button '2'
  SetWindowCallback(@WinCallback()) 
EndProcedure
Procedure SetColor(Color=-1)
  DisableGadget(#ColorPicker,1):
  If Color = -1
    Color = ColorRequester()
  EndIf
  StartDrawing(ImageOutput(#ColorPickerImage))
  Box(0,0,50,50,Color)
  StopDrawing()
  SetGadgetState(#ColorPicker,ImageID(#ColorPickerImage))
  If ListSize(XMLMainnode\Pxl()) > 0
    XMLMainnode\Pxl()\Color = Color
  EndIf
  DisableGadget(#ColorPicker,0) ; Ekliger Trick um Verschwinden des Gadgets zu verhindern
EndProcedure
Procedure MakeNewTree()
  ClearGadgetItems(#tree)
  ForEach XMLMainnode\Pxl()
    If ListSize(XMLMainnode\Pxl()\ExtractedInformation()) > 0
      AddGadgetItem(#tree,-1,XMLMainnode\Pxl()\Name,0,0)
      ForEach XMLMainnode\Pxl()\ExtractedInformation()
        AddGadgetItem(#tree,-1, XMLMainnode\Pxl()\ExtractedInformation(),0,1)
      Next
    EndIf
  Next
  For x = 0 To CountGadgetItems(#tree)
    SetGadgetItemState(#tree,x,#PB_Tree_Expanded)
  Next
  
EndProcedure
Procedure IsMouseOverGadget(Gadget) 
  GetWindowRect_(GadgetID(Gadget),GadgetRect.RECT) 
  GetCursorPos_(mouse.POINT) 
  If mouse\x>=GadgetRect\Left And mouse\x<=GadgetRect\right And mouse\y>=GadgetRect\Top And mouse\y<=GadgetRect\bottom 
    ProcedureReturn #True 
  Else 
    ProcedureReturn #False 
  EndIf 
EndProcedure

;Math
Procedure.q xEndian8(a.q) 
  b.q
  For i = 7 To 0 Step -1
    byte.a = PeekA(@a+i)
    ShowMemoryViewer(@b+7-i,1)
    PokeA(@b+7-i,byte)
  Next
  ProcedureReturn b
EndProcedure 
Procedure.i xEndian4(a.i) 
  !mov eax,[esp+4]
  !BSWAP eax
  ProcedureReturn 
EndProcedure 
Procedure.w xEndian2(a.w)
  ProcedureReturn a >> 8 + a << 8 
EndProcedure

;I-O
Procedure LoadInput(Filename.s = "") ; Returns number of bytes read.
  If Filename = ""
    Filename.s = OpenFileRequester("Datei laden",GetCurrentDirectory(),"*.*",-1)
  EndIf
  FileSize= FileSize(Filename)
  If FileSize <= 0
    ProcedureReturn -1
  ElseIf FileSize > 10000000
    MessageRequester("Fehler","Sorry, aber Dateien mit mehr als 10 Mb kann ich nicht.")
    ProcedureReturn -1
  EndIf
  
  DisableToolBarButton(Handles\Toolbar,#Toolbar_Speichern,0)
  f = ReadFile(#PB_Any,Filename)
  Offset = 0
  Repeat
    b.b = ReadByte(f)
    If b = #CR ; CR rauslöschen
      Continue
    EndIf
    PokeB(@FileString+Offset,b)
    Offset+1
  Until Offset = FileSize
  CloseFile(f)
  RePaintAll()
  MakeNewTree()
  ProcedureReturn Offset
EndProcedure
Procedure.s GetDropFile (*dropFiles, index)
  bufferNeeded = DragQueryFile_ (*dropFiles, index, 0, 0)
  For a = 1 To bufferNeeded: buffer$ + " ": Next ; Short by one character!
  DragQueryFile_ (*dropFiles, index, buffer$, bufferNeeded+1)
  ProcedureReturn buffer$
EndProcedure
Procedure LoadMaskFromFile(Filename.s="")
  If Filename = ""
    Filename.s = OpenFileRequester("Config Datei laden",GetCurrentDirectory(),"*.xml",-1)
  EndIf
  If LoadXML(#XML, Filename)
    ExtractXMLStructure(MainXMLNode(#XML),@XMLMainnode,pxl)
  EndIf
  ClearGadgetItems(Handles\ComboBox)
  
  ForEach XMLMainnode\Pxl()
    AddGadgetItem(Handles\ComboBox,-1,XMLMainnode\Pxl()\Name)
  Next
  SetGadgetState(Handles\ComboBox,0)
  
  UpdateDatenfeld(0)
  RePaintAll()
  MakeNewTree()
EndProcedure
Procedure SaveMaskToFile(Filename.s="")
  If Filename = ""
    Filename = SaveFileRequester("Config Datei speichern",GetCurrentDirectory(),"*.xml",-1)
  EndIf
  If CreateXML(#xml)
    InsertXMLStructure(RootXMLNode(#xml), @XMLMainnode, pxl)
    FormatXML(#xml, #PB_XML_ReFormat)
    SaveXML(#xml,Filename)
  EndIf
EndProcedure
Procedure SaveOutput()
  savefilename.s = SaveFileRequester("Bits speichern unter...",GetCurrentDirectory(),"*.txt",-1)
  f= OpenFile(#PB_Any,savefilename)
  If f
    For x = 0 To Filesize-1
      WriteByte(f,PeekB(@FileString+x))
    Next
    CloseFile(f)
  EndIf
EndProcedure
Procedure ConvertDirectoryToBinary(Path.s="")
  If Path = ""
    fdir.s = PathRequester("Verzeichnis konvertieren",GetCurrentDirectory())
  Else
    fdir = Path
  EndIf
  
  dir = ExamineDirectory(#PB_Any,fdir,"*.*")
  CreateDirectory(fdir + "bin\")
  
  While NextDirectoryEntry(dir)
    If DirectoryEntryName(dir) = "." Or DirectoryEntryName(dir) = ".." Or DirectoryEntryType(dir) = #PB_DirectoryEntry_Directory: Continue : EndIf
    f = OpenFile(#PB_Any,fdir + DirectoryEntryName(dir))
    b = CreateFile(#PB_Any,fdir+"bin\"+DirectoryEntryName(dir))
    While Eof(f) = 0
      WriteString(b,RSet(Bin(ReadAsciiCharacter(f)),8,"0"),#PB_Ascii)
    Wend
    CloseFile(b)
    CloseFile(f)
  Wend
  FinishDirectory(dir)
  MessageRequester("Fertig.","Das Verzeichnis wurde gewandelt. Die Ergebnisse liegen im /bin/ Unterordner.")
EndProcedure

;Interpret
Procedure OpenCurrentPxlNode()
  Name.s = GetGadgetItemText(Handles\ComboBox,GetGadgetState(Handles\ComboBox))
  ForEach XMLMainnode\Pxl()
    If XMLMainnode\Pxl()\Name = Name
      Break
    EndIf
  Next
EndProcedure
Procedure MasksActive(ok)
  If ok = 1
    SetGadgetText(Handles\MaskTitle,"Aktuelle Maske: ")
    SetGadgetText(#MaskTitle,XMLMainnode\Name)
    HideGadget(#MaskTitle,0)
  ElseIf ok = 0
    SetGadgetText(Handles\MaskTitle,"Aktuell keine Maske geladen.")
    HideGadget(#MaskTitle,1)
  EndIf
EndProcedure
Procedure Newmask()
  ClearList(XMLMainnode\Pxl())
  XMLMainnode\Name = ""
  ClearGadgetItems(Handles\ComboBox)
  For x = CountGadgetItems(Handles\ComboBox)-1 To 0 Step -1
    UpdateDatenfeld(x)
  Next
  MasksActive(1)
EndProcedure
Procedure RevealAlignment(Al)
  HideGadget(#Absolut_Start,1)
  HideGadget(#Absolut_Len,1)
  HideGadget(#Absolut_S_Text,1)
  HideGadget(#Absolut_E_Text,1)
  HideGadget(#Relativ_Ref,1)
  HideGadget(#Relativ_Off,1)
  HideGadget(#Relativ_O_T,1)
  HideGadget(#Relativ_R_T,1)
  HideGadget(#Regex_Input,1)
  HideGadget(#Regex_I_T,1)
  HideGadget(#Pointer_Start,1)
  HideGadget(#Pointer_Len,1)
  HideGadget(#Pointer_Off,1)
  HideGadget(#Pointer_Res,1)
  HideGadget(#Pointer_R_T,1)
  HideGadget(#Pointer_S_T,1)
  HideGadget(#Pointer_L_T,1)
  HideGadget(#Pointer_O_T,1)
  HideGadget(#WerteTabelleT,1)
  HideGadget(#WerteTabelleS,1)
  HideGadget(#WerteTabelleB,1)
  HideGadget(#Relativ_Len,1)
  HideGadget(#Relativ_L_T,1)
  HideGadget(#Pointer_Res,1)
  HideGadget(#Pointer_M_T,1)
  HideGadget(#Pointer_Mul,1)
  HideGadget(#Regex_Group,1)
  HideGadget(#Regex_Default,1)
  HideGadget(#Regex_D_T,1)
  Select al
    Case 0
      HideGadget(#Absolut_Start ,0)
      HideGadget(#Absolut_Len,0)
      HideGadget(#Absolut_S_Text,0)
      HideGadget(#Absolut_E_Text,0)
    Case 1
      HideGadget(#Regex_Input,0)
      HideGadget(#Regex_I_T,0)
      HideGadget(#Regex_Group,0)
      HideGadget(#Regex_Default,0)
      HideGadget(#Regex_D_T,0)
    Case 2
      HideGadget(#Pointer_Start,0)
      HideGadget(#Pointer_Len,0)
      HideGadget(#Pointer_Off,0)
      HideGadget(#Pointer_Res,0)
      HideGadget(#Pointer_R_T,0)
      HideGadget(#Pointer_S_T,0)
      HideGadget(#Pointer_L_T,0)
      HideGadget(#Pointer_O_T,0)  
      HideGadget(#Pointer_M_T,0)
      HideGadget(#Pointer_Mul,0)
    Case 3
      HideGadget(#WerteTabelleT,0)
      HideGadget(#WerteTabelleS,0)
      HideGadget(#WerteTabelleB,0)
    Case 4
      HideGadget(#Relativ_Ref,0)
      HideGadget(#Relativ_Off,0)
      HideGadget(#Relativ_O_T,0)
      HideGadget(#Relativ_R_T,0)
      HideGadget(#Relativ_Len,0)
      HideGadget(#Relativ_L_T,0)
  EndSelect
EndProcedure
Procedure UpdateDatenfeld(ID)
  If Id = -1 Or ListSize(XMLMainnode\Pxl()) <= 0
    ProcedureReturn -1
  EndIf
  
  ; ID ist der Jeweilige Eintrag im Datenfeld
  SelectElement(XMLMainnode\Pxl(),ID)
  RevealAlignment(XMLMainnode\Pxl()\Alignment)
  SetGadgetState(#AlignmentCombo,XMLMainnode\Pxl()\Alignment)
  If ListSize(XMLMainnode\Pxl()\StartXe()) > 0;TODO
    FirstElement(XMLMainnode\Pxl()\StartXe())
    SetGadgetText(#Absolut_Start,Str(XMLMainnode\Pxl()\StartXe()))
    SetGadgetText(#Pointer_Start,Str(XMLMainnode\Pxl()\StartXe()))
  EndIf
  SetGadgetText(#Absolut_Len,Str(XMLMainnode\Pxl()\Abs_Len))
  ClearGadgetItems(#Relativ_Ref)
  
  DeleteCircleReference = -1
  For i = 0 To CountGadgetItems(handles\ComboBox)-1
    AddGadgetItem(#Relativ_Ref,i,GetGadgetItemText(handles\ComboBox,i))
    If GetGadgetItemText(#Relativ_Ref,i) = XMLMainnode\Pxl()\ReferencePxlName
      SetGadgetState(#Relativ_Ref,i)
    ElseIf GetGadgetItemText(#Relativ_Ref,i) = XMLMainnode\Pxl()\Name
      DeleteCircleReference = i
    EndIf
  Next
  If DeleteCircleReference > -1
    RemoveGadgetItem(#Relativ_Ref,DeleteCircleReference)
  EndIf
  If GetGadgetState(#Relativ_Ref) = -1
    SetGadgetState(#Relativ_Ref,0)
    XMLMainnode\Pxl()\ReferencePxlName = GetGadgetText(#Relativ_Ref)
  EndIf
  
  SetGadgetText(#Relativ_Off,Str(XMLMainnode\Pxl()\ReferenceOffset))
  SetGadgetText(#Regex_Input,XMLMainnode\Pxl()\Regex)
  SetGadgetState(#Regex_Group,XMLMainnode\Pxl()\Regex_Grp)
  SetGadgetText(#Pointer_Len,Str(XMLMainnode\Pxl()\PointerLength))
  SetGadgetText(#Pointer_Off,Str(XMLMainnode\Pxl()\Offset))
  SetGadgetText(#WerteTabelleS,XMLMainnode\Pxl()\WerteTabelle)
  SetGadgetText(#Relativ_Len,Str(XMLMainnode\Pxl()\ReferenceLength))
  SetGadgetText(#Pointer_Mul,Str(XMLMainnode\Pxl()\Multiply))
  SetGadgetText(#Pointer_Res,Str(XMLMainnode\Pxl()\ResultLength))
  
  Select XMLMainnode\Pxl()\Type
    Case #PB_Byte
      SetGadgetState(#TypeSelector,0)
    Case #PB_Word
      SetGadgetState(#TypeSelector,1)
    Case #PB_Integer
      SetGadgetState(#TypeSelector,2)
    Case #PB_Quad
      SetGadgetState(#TypeSelector,3)
    Case #PB_String
      SetGadgetState(#TypeSelector,4)
  EndSelect
  Select XMLMainnode\Pxl()\Endianess
    Case #NoInterpret
      SetGadgetState(#EndianSelector,2)
    Case #LittleEndian
      SetGadgetState(#EndianSelector,1)
    Case #BigEndian
      SetGadgetState(#EndianSelector,0)
  EndSelect
  
  SetColor(XMLMainnode\Pxl()\Color)
EndProcedure
Procedure.s InterpretType(String.s, type.i, Endianess.i)
  Bytelen = Round(Len(string)/8,#PB_Round_Up)
  If Bytelen <= 0
    ProcedureReturn ""
  EndIf
  *BytePuffer = AllocateMemory(Bytelen)
  i= 0
  For x = 1 To Len(String) Step 8
    PokeB(*BytePuffer+i,Val("%"+Mid(String,x,8)))
    i+1
  Next
  Select Endianess
    Case #LittleEndian
      Select type
        Case #PB_Byte
          ProcedureReturn StrU(PeekB(*BytePuffer),#PB_Byte);k
        Case #PB_Word
          ProcedureReturn StrU(PeekW(*BytePuffer),#PB_Word);k
        Case #PB_Integer
          ProcedureReturn Str(PeekI(*BytePuffer))
        Case #PB_Quad 
          ProcedureReturn Str(PeekQ(*BytePuffer))
        Case #PB_String
          ProcedureReturn PeekS(*BytePuffer)
      EndSelect
    Case #BigEndian
      Select type
        Case #PB_Byte
          ProcedureReturn StrU(PeekB(*BytePuffer),#PB_Byte);k
        Case #PB_Word
          ProcedureReturn StrU(xEndian2(PeekW(*BytePuffer)),#PB_Word)
        Case #PB_Integer
          ProcedureReturn StrU(xEndian4(PeekI(*BytePuffer)),#PB_Integer)
        Case #PB_Quad 
          ProcedureReturn StrU(xEndian8(PeekQ(*BytePuffer)),#PB_Quad)
        Case #PB_String
          newstring.s = ""
          For x= Bytelen To 1 Step -1
            newstring + PeekA(*BytePuffer+x-1)
          Next
      EndSelect
    Case #NoInterpret
      ProcedureReturn String
  EndSelect
  
EndProcedure
Procedure CreateDataField(Name.s = "")
  AddElement(XMLMainnode\Pxl())
  If Name.s = ""
    XMLMainnode\Pxl()\Name = InputRequester("Name:","Bitte bennene das neue Datenfeld:","")
  Else
    XMLMainnode\Pxl()\Name = Name
  EndIf
  If XMLMainnode\Pxl()\Name <> ""
    AddGadgetItem(handles\ComboBox,-1,XMLMainnode\Pxl()\Name)
    SetGadgetState(Handles\ComboBox,CountGadgetItems(handles\ComboBox)-1)
    ClearList(XMLMainnode\Pxl()\StartXe())
    AddElement(XMLMainnode\Pxl()\StartXe())
    XMLMainnode\Pxl()\StartXe() = Val(GetGadgetText(#Absolut_Start))
    XMLMainnode\Pxl()\Alignment = 0
    XMLMainnode\Pxl()\Endianess = #NoInterpret:  XMLMainnode\Pxl()\Type = #PB_String
    XMLMainnode\Pxl()\Color = #Yellow
    l = ListIndex(XMLMainnode\Pxl())
    If l >= 0
      UpdateDatenfeld(l)
    EndIf
  EndIf
EndProcedure
Procedure RemoveDataField()
  ForEach XMLMainnode\Pxl()
    If XMLMainnode\Pxl()\Name = GetGadgetItemText(Handles\ComboBox,GetGadgetState(Handles\ComboBox))
      DeleteElement(XMLMainnode\Pxl())
      RemoveGadgetItem(Handles\ComboBox,GetGadgetState(Handles\ComboBox))
      Break
    EndIf
  Next
  SetGadgetState(Handles\ComboBox,0)
  OpenCurrentPxlNode()
EndProcedure

;Extract
Procedure AbsolutPaint(Lenx,Color)
  ClearList(XMLMainnode\Pxl()\ExtractedInformation())
  ForEach XMLMainnode\Pxl()\StartXe()
    Editor_Select(Handles\Editor, 0, XMLMainnode\Pxl()\StartXe(), 0,XMLMainnode\Pxl()\StartXe()+LenX)   
    Editor_BackColor(Handles\Editor,Color)
    AddElement(XMLMainnode\Pxl()\ExtractedInformation())
    XMLMainnode\Pxl()\ExtractedInformation() = InterpretType(Editor_Read(Handles\Editor,LenX),XMLMainnode\Pxl()\Type,XMLMainnode\Pxl()\Endianess)
  Next
EndProcedure
Procedure RelativPaint(XmlMainName.s,ReferenceName.s,ReferenzOffset,Offsetlength,Color)
  ForEach XMLMainnode\Pxl()
    If XMLMainnode\Pxl()\Name = XmlMainName
      l= ListIndex(XMLMainnode\Pxl())
      Break
    EndIf
  Next
  ClearList(XMLMainnode\Pxl()\ExtractedInformation())
  ClearList(XMLMainnode\Pxl()\StartXe())
  ForEach XMLMainnode\Pxl()
    If XMLMainnode\Pxl()\Name = ReferenceName
      ForEach XMLMainnode\Pxl()\StartXe()
        pos=XMLMainnode\Pxl()\StartXe()+ReferenzOffset
        Editor_Select(Handles\Editor,0,pos,0,pos+Offsetlength)
        Editor_BackColor(Handles\Editor,Color)
        PushListPosition(XMLMainnode\Pxl())
        
        SelectElement(XMLMainnode\Pxl(),l)
        AddElement(XMLMainnode\Pxl()\StartXe())
        XMLMainnode\Pxl()\StartXe() =pos
        AddElement(XMLMainnode\Pxl()\ExtractedInformation())
        XMLMainnode\Pxl()\ExtractedInformation() = InterpretType(Editor_Read(Handles\Editor,Offsetlength),XMLMainnode\Pxl()\Type,XMLMainnode\Pxl()\Endianess)
        
        PopListPosition(XMLMainnode\Pxl())
      Next
      Break
    EndIf
  Next
  SelectElement(XMLMainnode\Pxl(),l)
EndProcedure
Procedure OffsetPointerPaint(Leng,Endianess,Offset,Multiplikator,ResultLength,Color)
  If leng > 64
    MessageRequester("Fehler","Pointer mit mehr als 8 Bytes können nicht verarbeitet werden")
    ProcedureReturn -1
  EndIf
  If Not leng %8 = 0
    MessageRequester("Fehler","Pointer muss durch 8 teilbar sein.")
    ProcedureReturn -1
  EndIf
  If ListSize(XMLMainnode\Pxl()\StartXe()) = 0
    ProcedureReturn -1
  EndIf
  ClearList(XMLMainnode\Pxl()\ExtractedInformation())
  FirstElement(XMLMainnode\Pxl()\StartXe())
  Value.s = Mid(ReplaceString(ReplaceString(GetGadgetText(Handles\Editor),#CRLF$,#LF$),#TAB$," "),XMLMainnode\Pxl()\StartXe(),Leng)
  number.q = 0
  If Endianess = #LittleEndian
    For i = Len(Value)-7 To 1 Step -8
      number << 8
      number + Val("%"+Mid(Value,i,8))
    Next
  ElseIf Endianess = #BigEndian
    For i  = 1 To Len(Value) Step 8
      number << 8
      number + Val("%"+Mid(Value,i,8))
    Next
  ElseIf Endianess = #NoInterpret
    MessageRequester("Fehler","Die Interpretation eines Offsets braucht eine Endianess!")
    ProcedureReturn -1
  EndIf
  Editor_select(Handles\Editor,0,number*Multiplikator,0,number*Multiplikator+ResultLength)
  Editor_Backcolor(Handles\Editor,Color)
  AddElement(XMLMainnode\Pxl()\ExtractedInformation())
  XMLMainnode\Pxl()\ExtractedInformation() = InterpretType(Editor_Read(Handles\Editor,ResultLength),XMLMainnode\Pxl()\Type,XMLMainnode\Pxl()\Endianess)
  
EndProcedure
Procedure RegexPaint(Regex.s,GroupMode,Color)
  Reg = CreateRegularExpression(#PB_Any, Regex,#PB_RegularExpression_DotAll)
  If Not reg Or Regex = ""
    ProcedureReturn -1
  EndIf
  ExamineRegularExpression(Reg,ReplaceString(ReplaceString(GetGadgetText(Handles\Editor),#CRLF$,#LF$),#TAB$," ")) ;replacestring #cr gelöscht
  ClearList(XMLMainnode\Pxl()\StartXe())
  ClearList(XMLMainnode\Pxl()\ExtractedInformation())
  If GroupMode = 0
    While NextRegularExpressionMatch(Reg)
      AddElement(XMLMainnode\Pxl()\StartXe())
      XMLMainnode\Pxl()\StartXe() = RegularExpressionMatchPosition(Reg)
      Editor_Select(Handles\Editor, 0, RegularExpressionMatchPosition(Reg), 0,RegularExpressionMatchPosition(Reg)+RegularExpressionMatchLength(Reg))
      Editor_BackColor(Handles\Editor,Color)
      AddElement(XMLMainnode\Pxl()\ExtractedInformation())
      XMLMainnode\Pxl()\ExtractedInformation() = InterpretType(RegularExpressionMatchString(Reg),XMLMainnode\Pxl()\Type,XMLMainnode\Pxl()\Endianess)
    Wend
  ElseIf GroupMode = 1
    While NextRegularExpressionMatch(Reg)
      For i = 1 To CountRegularExpressionGroups(Reg)
        AddElement(XMLMainnode\Pxl()\StartXe())
        XMLMainnode\Pxl()\StartXe() = RegularExpressionMatchPosition(Reg)+RegularExpressionGroupPosition(Reg,i)-1
        Editor_Select(Handles\Editor, 0, RegularExpressionMatchPosition(Reg)+RegularExpressionGroupPosition(Reg,i)-1, 0,RegularExpressionMatchPosition(Reg)+RegularExpressionGroupPosition(Reg,i)+RegularExpressionGroupLength(Reg,i)-1)
        Editor_BackColor(Handles\Editor,Color)
        AddElement(XMLMainnode\Pxl()\ExtractedInformation())
        XMLMainnode\Pxl()\ExtractedInformation() = InterpretType(Mid(RegularExpressionMatchString(Reg),RegularExpressionGroupPosition(Reg,i),RegularExpressionGroupLength(reg,i)),XMLMainnode\Pxl()\Type,XMLMainnode\Pxl()\Endianess)
      Next
    Wend
  EndIf
  FreeRegularExpression(reg)
EndProcedure
Procedure WerteTabellePaint(Filename.s,Color)
  f = OpenFile(#PB_Any,Filename)
  If Not IsFile(f)
    ProcedureReturn 0
  EndIf
  
  Input.s = ReplaceString(ReplaceString(GetGadgetText(Handles\Editor),#CRLF$,#LF$),#TAB$," ")
  ClearList(XMLMainnode\Pxl()\StartXe())
  ClearList(XMLMainnode\Pxl()\ExtractedInformation())
  While Eof(f) = 0
    Codeword.s = ReadString(f)
    Repeat
      pos = FindString(Input,Codeword,lastpos+1)
      If pos > 0
        Editor_Select(Handles\Editor,0,pos,0,pos+Len(Codeword))
        AddElement(XMLMainnode\Pxl()\StartXe())
        XMLMainnode\Pxl()\StartXe() = pos
        AddElement(XMLMainnode\Pxl()\ExtractedInformation())
        XMLMainnode\Pxl()\ExtractedInformation() = Codeword
        Editor_BackColor(Handles\Editor,color)
      EndIf
      lastpos = pos
    Until pos = 0
  Wend
  CloseFile(f)
EndProcedure
Procedure Extract()
  ExtractString.s = ""
  ExtractString.s + XMLMainnode\Name+#LF$
  
  ForEach XMLMainnode\Pxl()
    ForEach XMLMainnode\Pxl()\ExtractedInformation()
      ExtractString +  Chr(9)+XMLMainnode\Pxl()\Name +":"+Chr(9)+XMLMainnode\Pxl()\ExtractedInformation()+#LF$
    Next
  Next
  MessageRequester("Fertig.","Extrahierte Daten liegen in der Zwischenablage.")
  SetClipboardText(ExtractString)
EndProcedure

Procedure RelativPreProcess() 
  Structure Verschacht
    List schach.colorcode()
  EndStructure
  NewList Verschachtelt.Verschacht()
  
  ForEach RelativSort()
    Referenz$ = RelativSort()\Name
    PushListPosition(RelativSort())
    ;Gibt es irgendeinen relativen Bezug auf dieses Element?
    Quelle = 1
    ForEach RelativSort()
      If RelativSort()\ReferencePxlName = Referenz$
        Quelle = 0
        Break  
      EndIf
    Next
    PopListPosition(RelativSort())
    ; Lege für jeden "tiefsten" Eintrag eine eigene Liste an
    If Quelle = 1
      AddElement(Verschachtelt())
      AddElement(Verschachtelt()\schach())
      CopyStructure(@RelativSort(),@Verschachtelt()\schach(),Colorcode)
      DeleteElement(RelativSort())
    EndIf
  Next
  ;Fülle beginnend bei den Quellen die Referenzen den Listen hinzu
  While ListSize(RelativSort()) > 0
    ;Für alle Quellen
    ForEach Verschachtelt()
      ;Den letzen Knoten nehmen
      FirstElement(Verschachtelt()\schach())
      Ref$ = Verschachtelt()\schach()\ReferencePxlName
      ;Suche eine noch früheren Knoten
      ForEach RelativSort()
        If Ref$ = RelativSort()\Name
          ;Füge den Knoten der Liste hinzu
          AddElement(Verschachtelt()\schach())
          CopyStructure(@RelativSort(),@Verschachtelt()\schach(),Colorcode)
          ;Lösche aus der Liste der verbleibenden Knoten
          DeleteElement(RelativSort())
          ;Schiebe den neuen Knoten auf die erste Position (damit die Quelle unten und die ersten Informationen oben stehen)
          MoveElement(Verschachtelt()\schach(), #PB_List_First)
        EndIf
      Next
    Next;Quelle für Quelle
        ;Bis alle Referenzen einer Verschachtelten Quell-Liste zugeordnet sind
  Wend
  
  ;Jetzt einfach die Verschachtelten Listen von oben nach unten abarbeiten
  ForEach Verschachtelt()
    ForEach Verschachtelt()\schach()
      RelativPaint(Verschachtelt()\schach()\Name,Verschachtelt()\schach()\ReferencePxlName,Verschachtelt()\schach()\ReferenceOffset,Verschachtelt()\schach()\ReferenceLength,Verschachtelt()\schach()\Color)
    Next
  Next
  
  FreeStructure(Verschacht)
  FreeList(Verschachtelt()\schach())
  FreeList(Verschachtelt())
EndProcedure
Procedure RePaintAll()
  HideGadget(Handles\Editor,1)
  Editor_Select(Handles\Editor, 0, 1, -1, -1)    
  Editor_BackColor(Handles\Editor,#White)
  
  SortStructuredList(XMLMainnode\Pxl(),#PB_Sort_Ascending,OffsetOf(ColorCode\Alignment),#PB_Integer)
  
  CopyList(XMLMainnode\Pxl(),RelativSort())
  
  If ListSize(RelativSort()) = 0
    HideGadget(Handles\Editor,0)
    ProcedureReturn 0
  EndIf
  
  ForEach XMLMainnode\Pxl()
    NextElement(RelativSort())
    Select XMLMainnode\Pxl()\Alignment
      Case 0 ;Absolut
        AbsolutPaint(XMLMainnode\Pxl()\Abs_Len,XMLMainnode\Pxl()\Color)
        DeleteElement(RelativSort()) 
        PreviousElement(RelativSort())
      Case 1 ;Regex
        RegexPaint(XMLMainnode\Pxl()\Regex,XMLMainnode\Pxl()\Regex_Grp,XMLMainnode\Pxl()\Color)
        DeleteElement(RelativSort())
        PreviousElement(RelativSort())
      Case 2 ;PointerOffset
        OffsetPointerPaint(XMLMainnode\Pxl()\PointerLength,XMLMainnode\Pxl()\Endianess,XMLMainnode\Pxl()\Offset,XMLMainnode\Pxl()\Multiply,XMLMainnode\Pxl()\ResultLength,XMLMainnode\Pxl()\Color)
        DeleteElement(RelativSort())
        PreviousElement(RelativSort())
      Case 3 ;WerteTabelle
        WerteTabellePaint(XMLMainnode\Pxl()\WerteTabelle,XMLMainnode\Pxl()\Color)
        DeleteElement(RelativSort())
        PreviousElement(RelativSort())
    EndSelect
  Next
  
  ;Check ob es die Referenz überhaupt gibt
  ForEach RelativSort()
    ReferenzGibtEsNicht = 1
    ForEach XMLMainnode\Pxl()
      If XMLMainnode\Pxl()\Name = RelativSort()\ReferencePxlName
        ReferenzGibtEsNicht = 0
        Break
      EndIf
    Next
    If ReferenzGibtEsNicht = 1
      MessageRequester("Fehler","Bezug auf nicht vorhandenes Element: "+RelativSort()\ReferencePxlName)
      Break
    EndIf
  Next
  If ListSize(RelativSort()) > 0 And ReferenzGibtEsNicht = 0
    RelativPreProcess()
    ClearList(RelativSort())
  EndIf
  Editor_Select(Handles\Editor, 0, 1, 0, 1) 
  HideGadget(Handles\Editor,0)
EndProcedure
Procedure.s CheckRegex(Regex.s)
  CreateRegularExpression(reg,Regex)
  error.s = RegularExpressionError()
  If error = ""
    FreeRegularExpression(reg)
  EndIf
  ProcedureReturn error
EndProcedure
Procedure.s Spruchvergleich(Spr1$,Nurladen=0)
  Spr1$ = RemoveString(Spr1$,#CR$)
  r = ArraySize(XORData(),1)
  i = ArraySize(XORData(),2)
  f = Len(Spr1$)
  
  If Nurladen = 1 And  InhaltSchonImXORArray <> StringFingerprint(Spr1$, #PB_Cipher_MD5)
    ;Speicher für den nächsten Spruch erzeugen(nicht dieser!)
    ReDim XORData(r,i+1)
  EndIf
  
  ;Lauflänge aufs Minimum
  If f < r+1
    r = f-1
  EndIf
  
  VergleichString.s = ""
  
  If Nurladen = 1
    If InhaltSchonImXORArray <> StringFingerprint(Spr1$, #PB_Cipher_MD5)
      For x = 0 To r
        XORData(x,i) = Asc(Mid(Spr1$,x+1,1))
      Next
      InhaltSchonImXORArray = StringFingerprint(Spr1$, #PB_Cipher_MD5)
    EndIf
    ProcedureReturn ""
  EndIf
  
  If i > 1 ; min. 2 Sprüche zum Vergleich
    For x = 0 To r
      Ref.b = XORData(x,0)
      Abbruch = 0
      For a = 1 To i-1
        If Not Ref.b ! XORData(x,a) = 0
          Abbruch = 1
        EndIf
      Next
      If Abbruch = 0
        VergleichString+"1"
      ElseIf Abbruch = 1
        VergleichString+"0"
      EndIf
    Next
  EndIf
  
  ProcedureReturn Left(VergleichString, r+1)
EndProcedure
Procedure FarbeBitPattern(Muster.s,MakeMask = 0)
  pos = 0
  HideGadget(Handles\Editor,1)
  Editor_Select(Handles\Editor, 0, 1, -1, -1)    
  Editor_BackColor(Handles\Editor,#White)
  If MakeMask = 1
    limit = Val(InputRequester("Begrenzer","Wie groß sollen die kleinsten Datenfelder werden?","1"))
    origin = -1
    Repeat
      pos = FindString(Muster,"1",pos+1)
      If lastpos +1 = pos
        If origin = -1
          origin = lastpos
        EndIf
      Else
        If origin > -1
          l = lastpos - origin
          origin+1
          If l >= limit
            CreateDataField("Vergleich_"+Str(pos))
            XMLMainnode\Pxl()\Color = #Gray
            XMLMainnode\Pxl()\StartXe() = origin
            XMLMainnode\Pxl()\Abs_Len = l
            UpdateDatenfeld(ListIndex( XMLMainnode\Pxl()))
          EndIf
        Else
          If limit = 1
            CreateDataField("Vergleich_"+Str(pos))
            XMLMainnode\Pxl()\Color = #Gray
            XMLMainnode\Pxl()\StartXe() = lastpos ; oder pos
            XMLMainnode\Pxl()\Abs_Len = 1
            UpdateDatenfeld(ListIndex( XMLMainnode\Pxl()))
          EndIf
        EndIf
        origin = -1
      EndIf
      lastpos = pos
    Until pos = 0
    RePaintAll()
  Else
    Repeat
      pos = FindString(Muster,"1",pos+1)
      Editor_Select(Handles\Editor,0,pos,0,pos+1)
      Editor_BackColor(Handles\Editor,RGB(220,220,220))
    Until pos = 0
  EndIf
  HideGadget(Handles\Editor,0)
EndProcedure

;MultiFileProcessing
Procedure ProcessMultipleFiles()    
  l = ListSize(MultiFiles())
  If l > 1
    Comp = MessageRequester("Mehrere Dateien","Sollen die Dateien automatisch verglichen werden?",#PB_MessageRequester_YesNo)
    DisableToolBarButton(Handles\Toolbar,#lastFile,0)
    ;Einmal alle bearbeiten
    ForEach MultiFiles()
      Filesize = LoadInput(MultiFiles()\Dateinamen)
      WriteEditor(@FileString,FileSize)
      Spruchvergleich(ReplaceString(ReplaceString(GetGadgetText(Handles\Editor),#CRLF$,#LF$),#TAB$," "),1)
    Next
  Else
    ;Den Letzten anzeigen
    Filesize = LoadInput(MultiFiles()\Dateinamen)
    WriteEditor(@FileString,FileSize)
  EndIf
  ;Den Letzten einfärben
  If comp = #PB_MessageRequester_Yes
    Muster.s = Spruchvergleich(ReplaceString(ReplaceString(GetGadgetText(Handles\Editor),#CRLF$,#LF$),#TAB$," "))
    FarbeBitPattern(Muster)    
  ElseIf l = 1
    RePaintAll()
    MakeNewTree()
  EndIf
  OpenCurrentPxlNode()
EndProcedure
Procedure LoadDirectory(Path.s = "")
  If Path.s = ""
    Path = PathRequester("Ordner auswählen",GetCurrentDirectory())
  EndIf
  ClearList(MultiFiles())
  dir = ExamineDirectory(#PB_Any,path,"*.*")
  While NextDirectoryEntry(dir)
    name.s = DirectoryEntryName(dir)
    If name = "." Or name = ".." : Continue : EndIf
    If DirectoryEntryType(dir) = #PB_DirectoryEntry_File
      AddElement(MultiFiles()) : MultiFiles()\Dateinamen = Path + name
    EndIf
  Wend
  FinishDirectory(dir)
  ProcessMultipleFiles()
EndProcedure
Procedure Navigate(Direction)
  If ListSize(MultiFiles()) = 0
    ProcedureReturn 0
  EndIf
  If ListIndex(MultiFiles())+ Direction = ListSize(MultiFiles()) Or ListIndex(MultiFiles())+ Direction < 0
    ProcedureReturn 0
  EndIf
  
  If direction = 1
    NextElement(MultiFiles())
    If ListIndex(MultiFiles())+1 = ListSize(MultiFiles())
      DisableToolBarButton(Handles\Toolbar,#NextFile,1)
    EndIf
    DisableToolBarButton(Handles\Toolbar,#LastFile,0)
  ElseIf Direction = -1
    PreviousElement(MultiFiles())
    If ListIndex(MultiFiles()) = 0
      DisableToolBarButton(Handles\Toolbar,#LastFile,1)
    EndIf
    DisableToolBarButton(Handles\Toolbar,#NextFile,0)
  EndIf
  
  Filesize = LoadInput(MultiFiles()\Dateinamen)
  WriteEditor(@FileString,FileSize)
  
  RePaintAll()
  MakeNewTree()
  
  OpenCurrentPxlNode()
EndProcedure
Procedure UpdateKeys()
  ForEach PushedKeys()
    If GetAsyncKeyState_(PushedKeys()) = 0
      DeleteElement(PushedKeys())
    EndIf
  Next
EndProcedure
Procedure KeyState(code) 
  If GetAsyncKeyState_(code) = 0: ProcedureReturn: EndIf 
  ForEach PushedKeys(): If PushedKeys() = code: exist = 1: EndIf: Next 
  If exist = 0: AddElement(PushedKeys()): PushedKeys() = code: ProcedureReturn 1: EndIf 
EndProcedure 
Procedure DatafieldByMenu(ID)
  ustring.s = ""
  Repeat
    unique = 1
    Name.s = InputRequester("Name", ustring+"Welchen Namen soll das Datenfeld erhalten?","")
    ForEach XMLMainnode\Pxl()
      If Name = XMLMainnode\Pxl()\Name
        unique = 0
        ustring = "Name schon vergeben. "
        Break
      EndIf
    Next
  Until unique = 1
  If name.s = ""
    ProcedureReturn 0
  EndIf
  
  If id > 3
    Relativename.s = GetMenuItemText(#EditorPopup,id)
  EndIf
  
  CreateDataField(Name)
  SendMessage_(GadgetID(Handles\Editor),#EM_EXGETSEL,0,Range.CHARRANGE) 
  
  Select ID
    Case 1 ; Absolut
      If Range\cpMax - (Range\cpMin+1) >0
        XMLMainnode\Pxl()\Abs_Len = Range\cpMax - Range\cpMin
        XMLMainnode\Pxl()\StartXe() = Range\cpMin+1
      EndIf
      XMLMainnode\Pxl()\Alignment = 0
    Case 2 ; Pointer+Offset
      XMLMainnode\Pxl()\StartXe() = Range\cpMin+1
      XMLMainnode\Pxl()\PointerLength = Range\cpMax - Range\cpMin
      XMLMainnode\Pxl()\Offset = 0
      XMLMainnode\Pxl()\ResultLength = 8
      XMLMainnode\Pxl()\Alignment = 2
    Case 3 ; Regex
      XMLMainnode\Pxl()\Regex = Mid(ReplaceString(ReplaceString(GetGadgetText(Handles\Editor),#CRLF$,#LF$),#TAB$," "),Range\cpMin+1,Range\cpMax-Range\cpMin)
      XMLMainnode\Pxl()\Regex_Grp = 0
      XMLMainnode\Pxl()\Alignment = 1
    Default; Relativ
      XMLMainnode\Pxl()\ReferencePxlName = Relativename
      PushListPosition(XMLMainnode\Pxl())
      p = 0
      ForEach XMLMainnode\Pxl()
        If XMLMainnode\Pxl()\Name = Relativename
          If ListSize(XMLMainnode\Pxl()\StartXe()) <> 1
            Break
          Else
            p = XMLMainnode\Pxl()\StartXe()
          EndIf
          Break
        EndIf
      Next
      PopListPosition(XMLMainnode\Pxl())
      
      If p > Range\cpMin
        MessageRequester("Fehler","Referenzpunkt muss vor dem Einsprung liegen.")
      Else
        Diff = Range\cpMin-p
        XMLMainnode\Pxl()\StartXe() = p+Diff
        XMLMainnode\Pxl()\ReferenceOffset = Diff
        XMLMainnode\Pxl()\ReferenceLength = Range\cpMax - Range\cpMin
      EndIf
      XMLMainnode\Pxl()\Alignment = 4
  EndSelect
  
  UpdateDatenfeld(ListIndex(XMLMainnode\Pxl()))
EndProcedure

GUI()
Repeat
  Event = WaitWindowEvent(1)
  If event
    ;Pfeiltasten
    UpdateKeys()
    If Not GetActiveGadget() = Handles\Editor
      If KeyState(#VK_RIGHT)
        Navigate(1)
      EndIf
      If KeyState(#VK_LEFT)
        Navigate(-1)
      EndIf
    EndIf
    
    ;Rechtsklick
    If GetAsyncKeyState_(#VK_RBUTTON) And IsMouseOverGadget(Handles\Editor)
      SendMessage_(GadgetID(Handles\Editor),#EM_EXGETSEL,0,Range.CHARRANGE) 
      ; Cursor auf Rechtsklick verschieben
      If Range\cpMax - Range\cpMin >0
        PostMessage_(GadgetID(Handles\Editor), #WM_LBUTTONDOWN, 0, EventlParam())
        WindowEvent()
      EndIf
      
      If IsMenu(#EditorPopup)
        FreeMenu(#EditorPopup)
      EndIf
      
      If CreatePopupMenu(#EditorPopup)
        MenuItem(1, "absolute Position übernehmen")
        MenuItem(2, "Pointer Position übernehmen")
        OpenSubMenu("relative Position übernehmen")
        max = CountGadgetItems(Handles\ComboBox)
        If max > 9999
          max = 9999 ; verhindert dass menuids des anderen menüs per enumeration zufällig diese id annehmen
        EndIf
        For x = 1 To max
          MenuItem(x+3,GetGadgetItemText(Handles\ComboBox,x-1))
        Next
        CloseSubMenu()
        MenuItem(3, "als Regex übernehmen")
      EndIf
      
      DisplayPopupMenu(#EditorPopup, WindowID(Handles\Window))
    EndIf
  EndIf
  
  Select Event
    Case #PB_Event_Menu
      Select EventMenu()
        Case 1 To 999 ; Relativ
          DatafieldByMenu(EventMenu())
        Case #LastFile
          Navigate(-1)
        Case #NextFile
          Navigate(1)
        Case #NewBitstream
          SetGadgetText(Handles\Editor,"")
        Case #Toolbar_Load
          Filesize = LoadInput()
          WriteEditor(@FileString,FileSize)
        Case #Toolbar_Speichern
          SaveOutput()
        Case #Toolbar_button_4
          Debug "button4"
        Case #Toolbar_button_5
          Debug "button5"
        Case #Toolbar_button_6
          Debug "button6"
        Case #SuchenStarten
          RePaintAll()
          MakeNewTree()
          OpenCurrentPxlNode()
        Case #Laden
          Filesize = LoadInput()
          WriteEditor(@FileString,FileSize)
        Case #SpeicherMasken
          SaveOutput()
        Case #NeueMaske
          Newmask()
        Case #LadenI
          LoadMaskFromFile()
          MasksActive(1)
        Case #SpeicherMaske
          SaveMaskToFile()
        Case #MakeAutoMask
          Spruchvergleich(ReplaceString(ReplaceString(GetGadgetText(Handles\Editor),#CRLF$,#LF$),#TAB$," "),1)
          BitPattern.s =  Spruchvergleich(ReplaceString(ReplaceString(GetGadgetText(Handles\Editor),#CRLF$,#LF$),#TAB$," "))
          FarbeBitPattern(BitPattern,1)
        Case #Vergleichen
          Spruchvergleich(ReplaceString(ReplaceString(GetGadgetText(Handles\Editor),#CRLF$,#LF$),#TAB$," "),1)
          BitPattern.s =  Spruchvergleich(ReplaceString(ReplaceString(GetGadgetText(Handles\Editor),#CRLF$,#LF$),#TAB$," "))
          FarbeBitPattern(BitPattern)
        Case #VerReset
          InhaltSchonImXORArray = ""
          Dim XORData.b(100000,0)
          Editor_Select(Handles\Editor, 0, 1, -1, -1)    
          Editor_BackColor(Handles\Editor,#White)
          Editor_Select(Handles\Editor, 0, 0, 0, 0)
        Case #Help;{
          RegexHelp.s = "Mögliche Ausdrücke"+#LF$
          RegexHelp + ".  Punkt ist ein Platzhalter('Wildcard') genau wie ? bei SQL. Beinhaltet auch einen Zeilenumbruch."+#LF$
          RegexHelp + "\  Muss vor Sonderzeichen stehen.\. wäre also ein Punkt."+#LF$
          RegexHelp + "\d Ziffer"+#LF$
          RegexHelp + "\D keine Ziffer"+#LF$
          RegexHelp + "\r Carriage Return =Zeilenvorschub (gibt es hier nicht!)"+#LF$
          RegexHelp + "\n LineFeed"+#LF$
          RegexHelp + "\w ASCII, Ziffer, Unterstrich"+#LF$
          RegexHelp + "\W kein ASCII, Ziffer, Unterstrich"+#LF$
          RegexHelp + "\s Leerzeichen, Tabulator, Zeilenumbruch, vertical Tab"+#LF$
          RegexHelp + "\S kein Leerzeichen, Tabulator, Zeilenumbruch, vertical Tab"+#LF$
          RegexHelp + "\t Tabulator"+#LF$
          RegexHelp + "() Fasse den enthaltenen Term als Gruppe zusammen"+#LF$
          RegexHelp + "(?:)  Der Term nach dem Doppelpunkt wird zwar als Gruppe zusammengefasst, kann aber nicht referenziert werden"+#LF$
          RegexHelp + "[] Die Werte in der Klammer sind an dieser Stelle erlaubt"+#LF$
          RegexHelp + "{x} Der vorherige Ausdruck kommt x Mal vor. Kann auch {1,5} 1 bis 5 lauten."+#LF$
          RegexHelp + "?  Der Wert vor dem Fragezeichen kann, muss aber nicht da sein"+#LF$
          RegexHelp + "*  Der Wert vor dem Sternchen kann beliebig oft vorkommen (kommt gar nicht vor ist auch erlaubt)"+#LF$
          RegexHelp + "+  Der Wert vor dem Plus kommt mindestens ein Mal vor"+#LF$
          RegexHelp + "| ODER. .[1|2] würde bedeuten, dass der Punkt nur 1 oder 2 sein darf."+#LF$
          RegexHelp + "[xYY]| YY wird hexadezimal gelesen .[x09] würde also nur einen Tabulator (Ascii-9) erlauben"+#LF$
          MessageRequester("REGEX-Reguläre Ausdrücke",RegexHelp);}
        Case #Extrahieren
          Extract()
        Case #DirLoad
          LoadDirectory()
        Case #Konvertieren
          ConvertDirectoryToBinary()
      EndSelect
    Case #WM_DROPFILES
      *dropped = EventwParam ()
      num.l = DragQueryFile_ (*dropped , $FFFFFFFF, temp$, 0)
      ClearList(MultiFiles())
      For index = 0 To num-1
        size.l = DragQueryFile_(*dropped, index, 0, 0) 
        filename.s = Space(size) 
        DragQueryFile_(*dropped, index, filename, size + 1)
        AddElement(MultiFiles()) : MultiFiles()\Dateinamen = filename
      Next
      DragFinish_ (*dropped)
      ProcessMultipleFiles()
    Case #PB_Event_Gadget
      Eventg = EventGadget()
      Select eventg
        Case #NewMaskField
          CreateDataField()
        Case #MaskTitle
          XMLMainnode\Name = GetGadgetText(#MaskTitle)
        Default 
          If ListSize(XMLMainnode\Pxl()) > 0
            Select eventg
              Case #Absolut_Len   : XMLMainnode\Pxl()\Abs_Len           = Val(GetGadgetText(#Absolut_Len))
              Case #Relativ_Ref   : XMLMainnode\Pxl()\ReferencePxlName  = GetGadgetText(#Relativ_Ref)
              Case #Relativ_Off   : XMLMainnode\Pxl()\ReferenceOffset   = Val(GetGadgetText(#Relativ_Off))
              Case #Relativ_Len   : XMLMainnode\Pxl()\ReferenceLength   = Val(GetGadgetText(#Relativ_Len))
              Case #Regex_Group   : XMLMainnode\Pxl()\Regex_Grp         = GetGadgetState(#Regex_Group)
              Case #Pointer_Len   : XMLMainnode\Pxl()\PointerLength     = Val(GetGadgetText(#Pointer_Len))
              Case #Pointer_Off   : XMLMainnode\Pxl()\Offset            = Val(GetGadgetText(#Pointer_Off))
              Case #Pointer_Res   : XMLMainnode\Pxl()\ResultLength      = Val(GetGadgetText(#Pointer_Res))
              Case #Pointer_Mul   : XMLMainnode\Pxl()\Multiply          = Val(GetGadgetText(#Pointer_Mul))
              Case #WerteTabelleS : XMLMainnode\Pxl()\WerteTabelle      = GetGadgetText(#WerteTabelleS)
              Case #Regex_Default
                ForEach Regex()
                  If Regex()\Name = GetGadgetText(#Regex_Default)
                    SetGadgetText(#Regex_Input,regex()\Command)
                    XMLMainnode\Pxl()\Regex = GetGadgetText(#Regex_Input)
                    Break
                  EndIf
                Next
              Case #Regex_Input
                XMLMainnode\Pxl()\Regex             = GetGadgetText(#Regex_Input)
                If Not CheckRegex(XMLMainnode\Pxl()\Regex) = ""
                  SetGadgetColor(#Regex_Input,#PB_Gadget_FrontColor,#Red)
                Else
                  SetGadgetColor(#Regex_Input,#PB_Gadget_FrontColor,#Black)
                EndIf
              Case #Absolut_Start
                ClearList(XMLMainnode\Pxl()\StartXe())
                AddElement(XMLMainnode\Pxl()\StartXe())
                XMLMainnode\Pxl()\StartXe() = Val(GetGadgetText(#Absolut_Start))
              Case #Pointer_Start
                ClearList(XMLMainnode\Pxl()\StartXe())
                AddElement(XMLMainnode\Pxl()\StartXe())
                XMLMainnode\Pxl()\StartXe() = Val(GetGadgetText(#Pointer_Start))
              Case #WerteTabelleB
                XMLMainnode\Pxl()\WerteTabelle = OpenFileRequester("Tabelle laden.",GetCurrentDirectory(),"*.*",-1)
                SetGadgetText(#WerteTabelleS,XMLMainnode\Pxl()\WerteTabelle)
              Case #ColorPicker
                Setcolor()
              Case #TypeSelector
                Select GetGadgetState(#TypeSelector)
                  Case 0
                    XMLMainnode\Pxl()\Type = #PB_Byte
                  Case 1
                    XMLMainnode\Pxl()\Type = #PB_Word
                  Case 2
                    XMLMainnode\Pxl()\Type = #PB_Integer
                  Case 3
                    XMLMainnode\Pxl()\Type = #PB_Quad
                  Case 4
                    XMLMainnode\Pxl()\Type = #PB_String
                EndSelect
              Case #EndianSelector
                If GetGadgetState(#EndianSelector) = 1 : XMLMainnode\Pxl()\Endianess = #LittleEndian
                ElseIf GetGadgetState(#EndianSelector) = 0 : XMLMainnode\Pxl()\Endianess = #BigEndian
                ElseIf GetGadgetState(#EndianSelector) = 2 : XMLMainnode\Pxl()\Endianess = #NoInterpret
                EndIf
              Case #AlignmentCombo
                If ListSize(XMLMainnode\Pxl()) > 0
                  XMLMainnode\Pxl()\Alignment = GetGadgetState(#AlignmentCombo)
                  RevealAlignment(XMLMainnode\Pxl()\Alignment)
                EndIf
              Case #DeleteMaskField  
                RemoveDataField()
                OpenCurrentPxlNode()
                UpdateDatenfeld(ListIndex(XMLMainnode\Pxl()))
              Case Handles\ComboBox
                OpenCurrentPxlNode()
                UpdateDatenfeld(ListIndex(XMLMainnode\Pxl()))
            EndSelect
          EndIf
      EndSelect
    Case #PB_Event_CloseWindow
      Quit = 1
    Default
      lastevent =event
      SendMessage_(GadgetID(Handles\Editor),#EM_EXGETSEL,0,Range.CHARRANGE) 
      If ListSize(MultiFiles()) > 0
        Dateiname.s = "     "+MultiFiles()\Dateinamen
      Else
        Dateiname.s = ""
      EndIf
      SetWindowText_(WindowID(Handles\Window),"BitMasker von J.S."+Chr(9)+"Position: "+Str(Range\cpMin+1)+"(+"+Str(Range\cpMax-Range\cpMin)+") bis "+Str(Range\cpMax+1)+DateiName.s) 
  EndSelect
Until Quit = 1

DataSection
  Newmask:
  IncludeBinary "New.png"
  Deletemask:
  IncludeBinary "Delete.png"
  Left:
  IncludeBinary "arrow_left.png"
  Right:
  IncludeBinary "arrow_right.png"
  image3:
  IncludeBinary "New.png"
  image4:
  IncludeBinary "Open.png"
  image5:
  IncludeBinary "Save.png"
  image6:
  IncludeBinary "Cut.png"
  image7:
  IncludeBinary "Copy.png"
  image8:
  IncludeBinary "Paste.png"
  image9:
  IncludeBinary "Find.png"
EndDataSection
; IDE Options = PureBasic 5.73 LTS (Windows - x64)
; CursorPosition = 687
; FirstLine = 383
; Folding = AYAAIAAA+
; EnableThread
; EnableXP
; DPIAware
; UseIcon = New2.ico
; Executable = BitMasker.exe