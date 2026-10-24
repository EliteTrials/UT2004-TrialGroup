class HUD_AssaultExt extends HUD_Assault;

#exec TEXTURE IMPORT NAME=InfoBracket FILE=Resources\InfoBracket.dds MIPS=OFF ALPHA=1 LODSET=5 DXT=5 UCLAMPMODE=TC_Clamp VCLAMPMODE=TC_Clamp

var const Material BracketTexture;

// Copy paste from HUD_Assault.Draw_2DCollisionBox
static function Draw_2DCollisionBox( Canvas C, Actor A, Vector ScrPos, String Description, float ColExpand, bool bSizeOverride )
{
	local vector	TmpScrCorner[2], ScrCornerY[2], ScrCornerX[2];
	local float		XL, YL, X, Y, BXL, BYL;
	local vector	CameraLocation;
	local rotator	CameraRotation;

	C.GetCameraLocation( CameraLocation, CameraRotation );
	C.Style = ERenderStyle.STY_Alpha;

	// Get Box Height...
	if ( CameraLocation.Z < A.Location.Z )
	{
		ScrCornerY[0] = GetScreenCorner( C, A, Vect( 1, 0, 1), ScrPos, CameraRotation, ColExpand );	// Top Front
		ScrCornerY[1] = GetScreenCorner( C, A, Vect(-1, 0,-1), ScrPos, CameraRotation, ColExpand );	// Bottom Back
	}
	else
	{
		ScrCornerY[0] = GetScreenCorner( C, A, Vect(-1, 0, 1), ScrPos, CameraRotation, ColExpand );	// Top Back
		ScrCornerY[1] = GetScreenCorner( C, A, Vect( 1, 0,-1), ScrPos, CameraRotation, ColExpand );	// Bottom Front
	}

	// Get Width of box...
	TmpScrCorner[0] = GetScreenCorner( C, A, Vect( 0, 1, 1), ScrPos, CameraRotation, ColExpand ); // Left Top
	TmpScrCorner[1] = GetScreenCorner( C, A, Vect( 0, 1,-1), ScrPos, CameraRotation, ColExpand ); // Left Bottom
	ScrCornerX[0].X	= Max( TmpScrCorner[0].X, TmpScrCorner[1].X );

	TmpScrCorner[0] = GetScreenCorner( C, A, Vect( 0,-1, 1), ScrPos, CameraRotation, ColExpand ); // Right Top
	TmpScrCorner[1] = GetScreenCorner( C, A, Vect( 0,-1,-1), ScrPos, CameraRotation, ColExpand ); // Right Bottom
	ScrCornerX[1].X	= Max( TmpScrCorner[0].X, TmpScrCorner[1].X );

	// Description Text
	if ( Description != "" )
	{
		C.StrLen(Description, XL, YL);

		// Description Clipping
		TmpScrCorner[0].X = ScrPos.X - XL*0.5;
		TmpScrCorner[0].Y = ScrPos.Y - ScrCornerY[0].Y - YL;
		if ( TmpScrCorner[0].Y < 0 )
			TmpScrCorner[0].Y = 0;

		// Drawing Description
		C.SetPos(TmpScrCorner[0].X, TmpScrCorner[0].Y);
		C.DrawText(Description, false);
	}

	BXL = 16.f * C.SizeX / 640.f;
	BYL = 16.f * C.SizeY / 480.f;

	// Maximum BOX overlapping (skip drawing when too small)
	if ( ScrCornerX[0].X + ScrCornerX[1].X < BXL )
	{
		if ( !bSizeOverride )
			return;

		ScrCornerX[0].X = BXL*0.5;
		ScrCornerX[1].X = BXL*0.5;
	}
	if ( ScrCornerY[0].Y + ScrCornerY[1].Y < BYL )
	{
		if ( !bSizeOverride )
			return;

		ScrCornerY[0].Y = BYL*0.5;
		ScrCornerY[1].Y = BYL*0.5;
	}

	// Top left corner
	X = FMax( ScrPos.X - ScrCornerX[0].X, 0 );
	Y = FMax( ScrPos.Y - ScrCornerY[0].Y, YL );
	C.SetPos(X, Y);
	C.DrawTile(default.BracketTexture, BXL, BYL, 0.f, 0.f, 32.f, 32.f);

	// Top right corner
	X = FMin( ScrPos.X + ScrCornerX[1].X - BXL, C.ClipX - BXL );
	Y = FMax( ScrPos.Y - ScrCornerY[0].Y, YL );
	C.SetPos(X, Y);
	C.DrawTile(default.BracketTexture, BXL, BYL, 0.f, 0.f, -32.f, 32.f);

	// Bottom left corner
	X = FMax( ScrPos.X - ScrCornerX[0].X, 0 );
	Y = FMin( ScrPos.Y + ScrCornerY[1].Y - BYL, C.ClipY - BYL );
	C.SetPos(X, Y);
	C.DrawTile(default.BracketTexture, BXL, BYL, 0.f, 0.f, 32.f, -32.f);

	// Bottom right corner
	X = FMin( ScrPos.X + ScrCornerX[1].X - BXL, C.ClipX - BXL );
	Y = FMin( ScrPos.Y + ScrCornerY[1].Y - BYL, C.ClipY - BYL );
	C.SetPos(X, Y);
	C.DrawTile(default.BracketTexture, BXL, BYL, 0.f, 0.f, -32.f, -32.f);
}

defaultproperties
{
    begin object name=oBracketFinalBlend class=FinalBlend
        FrameBufferBlending=FB_AlphaBlend
        Material=Texture'InfoBracket'
    end object
    
    BracketTexture=oBracketFinalBlend
}