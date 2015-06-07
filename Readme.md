CCR.Clipboard
=============

Extended TClipboard implementation for FMX and VCL. Compiles with Delphi XE2 and up for desktop FMX and the VCL, XE6 and up for iOS. Where the platform allows, supports delayed rendering, virtual files, change notifications, and inter-process TClipboard-based drag and drop.

Platform support
----------------

* Custom formats along with copying and pasting text, components, graphics, files, and URLs are all supported on Windows, OS X and iOS.

* Delayed rendering, TClipboard-based drag and drop, and virtual files are supported on Windows and OS X, although in the case of the latter Finder only supports virtual files being dragged to it, not pasted as well. For FMX, drag and drop also requires XE7 or later.

* Change notifications require Vista or later on Windows.

* Writing multiple instances of the same format is supported generically on OS X and iOS. On Windows it is only supported for files, virtual files and Delphi components; attempting to write the same format multiple times otherwise will just overwrite the previous attempt.

* At present Android is only nominally supported with a text-only backend that delegates to the standard FMX clipboard code.

Example usage
-------------

### Testing for readable data

**_Test for whether plain text, a URL or a TBitmap can be read from the clipboard_**

	if Clipboard.HasText then //...
	if Clipboard.HasURL then //...
	if Clipboard.HasFormatFor(TBitmap) then //...

**_Test for a specific format being available_**

	if Clipboard.HasFormat(cfPNG) then //...

**_Test for whether at least one format in a group is available, returning the first one found_**

	var
	  Matched: TClipboardFormat;
	begin
	  if Clipboard.HasFormat([cfPNG, cfTIFF], Matched) then //...

**_Enumerate all formats on the clipboard_**

	var
	  ClipFormat: TClipboardFormat;
	begin
	  for ClipFormat in Clipboard do
	    ShowMessage(ClipFormat.Name);
	  

### Copying and pasting

**_Copy and paste plain text_**

	Clipboard.AsText := 'Hello world';
	S := Clipboard.AsText;

**_Copy two files and a URL_**

	Clipboard.Open;
	try
	  Clipboard.AssignFile(SomeFileName1); //file must exist!
	  Clipboard.AssignFile(SomeFileName2); //ditto
	  Clipboard.AssignURL('http://www.bbc.co.uk/');
	finally
	  Clipboard.Close;
	end;

**_Copy two pieces of text_**

	Clipboard.Open;
	try
	  Clipboard.AssignText('First item');
	  Clipboard.AssignText('Second item');
	finally
	  Clipboard.Close;
	end;

Works on Apple platforms; on Windows the first item will get overwritten by the second.

**_Copy and paste a TBitmap_**

	Clipboard.Assign(Bitmap);
	Bitmap.Assign(Bitmap);

Requires either CCR.Clipboard.VCL or CCR.Clipboard.FMX (as applicable) to be used somewhere to link in framework-specific code.

**_Show all plain text, URLs, file names, and virtual file descriptors on the clipboard_**

	for S in Clipboard.GetText do
	  ShowMessage(S);
	for S in Clipboard.GetURLs do
	  ShowMessage(S);
	for S in Clipboard.GetFileNames do
	  ShowMessage(S);
	for S in Clipboard.GetVirtualFileDescriptors do
	  ShowMessage(S);

**_Paste the data for each virtual file into a local variable and show its size_**

	Clipboard.EnumVirtualFiles(
	  procedure (const Descriptor: string; const GetBytes: TFunc<TBytes>;
	    var LookForMore: Boolean)
	  var
	    Data: TBytes;
	  begin
	    Data := GetBytes;
	    ShowMessageFmt('%d bytes', [Length(Data)]);
	  end);

A TStream version is also available:

	Clipboard.EnumVirtualFiles(
	  procedure (const Descriptor: string; const SaveToStream: TProc<TStream>;
	    var LookForMore: Boolean)
	  var
	    Stream: TStream;
	  begin
	    Stream := TMemoryStream.Create;
	    try
	      SaveToStream(Stream);
	      ShowMessageFmt('%d bytes', [Stream.Size]);
	    finally
	      Stream.Free;
	    end;
	  end);

A further variant writes virtual files to a directory of your choice:

	Clipboard.SaveVirtualFiles(PathToExistingDir, memPastedFileNames.Lines);

**_Paste as many TBitmap instances as can be read into a TObjectList_**

	FBitmaps.Clear;
	Clipboard.GetObjects<TBitmap>(
	  procedure (const AssignTo: TProc<TBitmap>; var LookForMore: Boolean)
	  var
	    Bitmap: TBitmap;
	  begin
	    Bitmap := TBitmap.Create;
	    FBitmaps.Add(Bitmap);
	    AssignTo(Bitmap);
	  end);

**_Copy a delay-rendered TBitmap_**

	Clipboard.AssignDelayed<TBitmap>(
	  procedure (BitmapToRender: TBitmap)
	  begin
	    BitmapToRender.SetSize(100, 100);
	    //...
	  end);

**_Copy delay-rendered text_**

	Clipboard.AssignTextDelayed(
	  function : string
	  begin
	    Result := 'This is just an example generated at ' + DateTimeToStr(Now);
	  end);

**_Copy the contents of a FMX TImage as a virtual file_**

	Clipboard.AssignVirtualFile('Example.png', Image1.Bitmap);

**_Copy a delay-rendered virtual text file_**

	Clipboard.AssignVirtualFileDelayed('Example.txt', 
	  function : string
	  begin
	    Result := 'This is just an example generated at ' + DateTimeToStr(Now);
	  end);

### Custom formats

**_Register a custom format_**

	var
	  cfMyDoc: TClipboardFormat;

	cfMyDoc := Clipboard.RegisterFormat('com.mycompany.mydoc');

A UTI string as shown is preferred on Apple platforms, though technically anything can be used.

**_Copy data as the custom format_**

	Clipboard.Assign(cfMyDoc, SomeBytes);

**_Register a TPersistent class (TBrush in this case) using a default 'clipper', and copy an instance_**

	TClipboard.RegisterSimpleClipper<TBrush>;
	Clipboard.Assign(Rectangle1.Fill);

**_Paste the brush back in after checking an instance can be read first_**

	if Clipboard.HasFormatFor(TBrush) then
	  Rectangle1.Fill.Assign(Clipboard);

Alternatively (and perhaps preferably) the GetObjects syntax can be used:

	Clipboard.GetObjects<TBrush>(
	  procedure (const AssignTo: TProc<TBrush>; var LookForMore: Boolean)
	  begin
	    AssignTo(Rectangle1.Fill);
	    LookForMore := False;
	  end);

### Drag and drop

**_Dragging the contents of a VCL TImage_**

Add CCR.Clipboard.VCL to the uses clause and handle the control's OnMouseDown event to call TClipboard.BeginDrag as appropriate:

	procedure TMyForm.imgDragSourceMouseDown(Sender: TObject; Button: TMouseButton;
	  Shift: TShiftState; X, Y: Integer);
	begin
	  if (Button = mbLeft) and not imgDragSource.Picture.Graphic.Empty then
	    TClipboard.BeginDrag(Image1,
	      procedure (Clipboard: TClipboard)
	      begin
	        Clipboard.Assign(Image.Picture);
	      end);
	end;

If you prefer you can use a regular method instead of an anonymous one for the callback:

	procedure TMyForm.ImageBeginDrag(Source: TObject; Clipboard: TClipboard)
	begin
	  Clipboard.Assign((Source as TImage).Picture);
	end);

	procedure TMyForm.imgDragSourceMouseDown(Sender: TObject; Button: TMouseButton;
	  Shift: TShiftState; X, Y: Integer);
	begin
	  if (Button = mbLeft) and not imgDragSource.Picture.Graphic.Empty then
	    TClipboard.BeginDrag(Image1, ImageBeginDrag);
	end;

**_Dragging the contents of a FMX TImage_**

1) Add CCR.Clipboard.FMX to the uses clause and ensure the form is registered for TClipboard-based drag and drop:

	procedure TMyForm.FormCreate(Sender: TObject);
	begin
	  TClipboard.RegisterForDragAndDrop(Self);
	end;

2) *Either* set the image's DragMode property in the Object Inspector to dmAutomatic *or* initiate a drag operation explicitly like in the VCL case:

	procedure TMyForm.imgDragSourceMouseDown(Sender: TObject; Button: TMouseButton;
	  Shift: TShiftState; X, Y: Single);
	begin
	  if (Button = mbLeft) and not imgDragSource.Bitmap.IsEmpty then
	    TClipboard.BeginDrag(Image1,
	      procedure (Clipboard: TClipboard)
	      begin
	        Clipboard.Assign(Image1.Bitmap);
	      end);
	end;

**_Making a VCL TImage a drop target for pictures_**

Each VCL control that wishes to be a drop target must be registered as such:

	procedure TMyForm.FormCreate(Sender: TObject);
	begin
	  TClipboard.RegisterDropTargets([imgDropTarget]);
	end;

Once that is done standard VCL drag and drop events can be handled to accept a TClipboard source:

	procedure TMyForm.imgDropTargetDragOver(Sender, Source: TObject; X, Y: Integer;
	  State: TDragState; var Accept: Boolean);
	begin
	  Accept := (Source is TClipboard) and TClipboard(Source).HasFormatFor(TPicture);
	end;

	procedure TMyForm.imgDropTargetDragDrop(Sender, Source: TObject; X, Y: Integer);
	begin
	  imgDropTarget.Picture.Assign(Source as TClipboard);
	end;

Data can be dragged from either internal or external sources, e.g. a picture in a Word document or a PNG file dragged from Explorer.

**_Making a FMX TImage a drop target for pictures_**

1) Ensure the form is registered for TClipboard-based drag and drop:

	procedure TMyForm.FormCreate(Sender: TObject);
	begin
	  TClipboard.RegisterForDragAndDrop(Form);
	end;

2) Handle standard FMX drag and drop events:

	procedure TMyForm.imgDropTargetDragOver(Sender: TObject; 
	  const Data: TDragObject; const Point: TPointF; var Operation: TDragOperation);
	begin
	  if (Data.Source is TClipboard) and TClipboard(Data.Source).HasFormatFor(TBitmap) then
	    Operation := TDragOperation.Copy
	  else
	    Operation := TDragOperation.None;
	end;

	procedure TMyForm.imgDropTargetDragDrop(Sender: TObject;
	  const Data: TDragObject; const Point: TPointF);
	begin
	  imgDropTarget.Bitmap.Assign(Data.Source as TClipboard);
	end;

Demos
-----

For further sample code, check out the demos -

- *VCL:* demonstrates a simple clipboard viewer, copying a range of formats, pasting, and 
drag and drop (Windows)

- *FMX desktop, XE2+:* demonstrates the basics of copying and pasting, including a custom format (Windows and OS X)

- *FMX desktop, XE6+:* similar the VCL demo, demonstrates a simple clipboard viewer, copying a range of formats, pasting, and drag and drop (Windows and OS X)

- *FMX mobile:* mobile version of the XE6+ desktop demo, less drag and drop (iOS)

- *RegisterSimpleClipper and GetObjects:* demo of registering and putting to work a default clipper for a TPersistent descendant (Windows, OS X, iOS)

- *Custom record clipper:* demonstrates writing a custom clipper for TRectF (Windows, OS X, iOS)

- *Multiple format sets:* simple example of NewFormatSet and EnumFormatSets (OS X and iOS)

- *Custom clipboard:* demo of a system-managed private clipboard (OS X and iOS)