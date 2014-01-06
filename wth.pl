#! /usr/bin/perl
=head1 NAME

 obj2opengl - converts obj files to arrays for glDrawArrays
 
=head1 SYNOPSIS

 obj2opengl [options] file

 use -help or -man for further information

=head1 DESCRIPTION

This script expects and OBJ file consisting of vertices,
texture coords and normals. Each face must contain
exactly 3 vertices. The texture coords are two dimonsional.

The resulting .H file offers three float arrays to be rendered
with glDrawArrays.

=head1 AUTHOR

Heiko Behrens (http://www.HeikoBehrens.net)

=head1 VERSION

14th August 2012

=head1 COPYRIGHT

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

=head1 ACKNOWLEDGEMENTS

This script is based on the work of Margaret Geroch.

=head1 REQUIRED ARGUMENTS

The first or the last argument has to be an OBJ file according 
to this () specification.

=head1 OPTIONS

=over

=item B<-help>

Print a brief help message and exits.

=item B<-man>

Prints the extended manual page and exits.

=item B<-noScale>    

Prevents automatic scaling. Otherwise the object will be scaled
such the the longest dimension is 1 unit.

=item B<-scale <float>>

Sets the scale factor explicitly. Please be aware that negative numbers
are not handled correctly regarding the orientation of the normals.

=item B<-noMove>

Prevents automatic scaling. Otherwise the object will be moved to the center of
its vertices.

=item B<-o>, B<-outputFilename>

Name of the output file name. If omitted, the output file the same as the
input filename but with the extension .h

=item B<-nameOfObject>

Specifies the name of the generated variables. If omitted, same as 
output filename without path and extension.

=item B<-noverbose>

Runs this script silently.
   
=cut
use utf8;
use File::Path;
use Cwd 'abs_path';
use Getopt::Long;
use File::Basename;
use Pod::Usage;

# -----------------------------------------------------------------
# Main Program
# -----------------------------------------------------------------
handleArguments();

    if($verbose)
    {
        printInputAndOptions();
    }

    calcSizeAndCenter();

    # TODO check integrity: Does every referenced vertex, normal and coord exist?
    loadData();
    
    normalizeNormals();

    openFileAndTypeInTheBeginning();

    writeOutput();


    if($verbose)
    {
        printStatistics();
    }

# -----------------------------------------------------------------
# Sub Routines
# -----------------------------------------------------------------

sub handleArguments() {
	my $help = 0;
	my $man = 0;
	my $noscale = 0;
	my $nomove = 0;
    glob $outFoldername;
    glob $inFoldername;
    glob $outFileNameWithoutExtension;
    
	$verbose = 1;
	$errorInOptions = !GetOptions (
		"help" => \$help,
		"man"  => \$man,
		"noScale" => \$noscale,
		"scale=f" => \$scalefac,
		"noMove" => \$nomove,
		"center=f{3}" => \@center,
		"outputFilename=s" => \$outFilename,
		"nameOfObject=s" => \$object,
		"verbose!" => \$verbose,
		);
	
	if($noscale) {
		$scalefac = 1;
	}
	
	if($nomove) {
		@center = (0, 0, 0);
	}
	
	if(@center) {
		$xcen = $center[0];
		$ycen = $center[1];
		$zcen = $center[2];
	}
	
    my $argvSize = @ARGV;
    
    if($argvSize > 0)
	{
		my ($file, $dir, $ext) = fileparse($ARGV[0], qr/\.[^.]*/);
		$inFilename = $dir . $file . $ext;
	}
	else 
	{
		$errorInOptions = true;
	}
  
    
    my ($file2, $dir2, $ext2) = fileparse(abs_path($inFilename), qr/\.[^.]*/);
	
    $inFoldername = $dir2;
    
    
    # (optional) derive output filename from input filename
	unless($errorInOptions || defined($outFilename)) {
		my ($file, $dir, $ext) = fileparse($inFilename, qr/\.[^.]*/);
		$outFilename = $dir . $file; # . ".h"
        $outFileNameWithoutExtension = $dir . $file;
	}
    
    # (optional) derive output filename from input filename
	unless($errorInOptions || defined($outFoldername)) {
		my ($file, $dir, $ext) = fileparse($inFilename, qr/\.[^.]*/);
		$outFoldername = $dir . $file . "Data/";
	}
	
	# (optional) define object name from output filename
	unless($errorInOptions || defined($object)) {
		my ($file, $dir, $ext) = fileparse($outFilename, qr/\.[^.]*/);
	  	$object = $file;
	}
	
    
    
    print "\n\n";
    
    print "original folder = ", $inFoldername;
    
    print "\n\n";
    
    print "new folder = ", $outFoldername;
    
    print "\n\n";
    
    
    
	($inFilename ne $outFilename) or
		die ("Input filename must not be the same as output filename")
		unless($errorInOptions);
		
	if($errorInOptions || $man || $help) {
		pod2usage(-verbose => 2) if $man;
		pod2usage(-verbose => 1) if $help;
		pod2usage(); 
	}
	
    chdir($inFoldername);
    
	# check wheter file exists
	open ( INFILE, "<$inFilename" ) 
	  || die "Can't find file '$inFilename' ...exiting \n";
	close(INFILE);
}

# Stores center of object in $xcen, $ycen, $zcen
# and calculates scaling factor $scalefac to limit max
#   side of object to 1.0 units
sub calcSizeAndCenter() {

    chdir($inFoldername);
    
    
	open ( INFILE, "<$inFilename" ) 
	  || die "Can't find file $inFilename...exiting \n";

	$numVerts = 0;
	
	my (
		$xsum, $ysum, $zsum,
		$xmin, $ymin, $zmin,
		$xmax, $ymax, $zmax,
		);

    
    my $objCounter = 0;
    
	while ( $line = <INFILE> ) 
	{
        chop $line;
	  

    if ($line =~ /o\s+.*/)
    {
        $objCounter++;
    }


        
	  if ($line =~ /v\s+.*/)
	  {
	  
	    $numVerts++;
	    @tokens = split(' ', $line);
	    
	    $xsum += $tokens[1];
	    $ysum += $tokens[2];
	    $zsum += $tokens[3];
	    
	    if ( $numVerts == 1 )
	    {
	      $xmin = $tokens[1];
	      $xmax = $tokens[1];
	      $ymin = $tokens[2];
	      $ymax = $tokens[2];
	      $zmin = $tokens[3];
	      $zmax = $tokens[3];
	    }
	    else
	    {   
	        if ($tokens[1] < $xmin)
	      {
	        $xmin = $tokens[1];
	      }
	      elsif ($tokens[1] > $xmax)
	      {
	        $xmax = $tokens[1];
	      }
	    
	      if ($tokens[2] < $ymin) 
	      {
	        $ymin = $tokens[2];
	      }
	      elsif ($tokens[2] > $ymax) 
	      {
	        $ymax = $tokens[2];
	      }
	    
	      if ($tokens[3] < $zmin) 
	      {
	        $zmin = $tokens[3];
	      }
	      elsif ($tokens[3] > $zmax) 
	      {
            $zmax = $tokens[3];
	      }
	    
	    }
	 
	  }
	 
	}
	close INFILE;
	
	#  Calculate the center
	#unless(defined($xcen)) {
		$xcen = sprintf "%.3f", ($xsum / $numVerts);
		$ycen = sprintf "%.3f", ($ysum / $numVerts);
		$zcen = sprintf "%.3f", ($zsum / $numVerts);
	#}
	
	#  Calculate the scale factor
	unless(defined($scalefac)) {
		my $xdiff = ($xmax - $xmin);
		my $ydiff = ($ymax - $ymin);
		my $zdiff = ($zmax - $zmin);
		
		if ( ( $xdiff >= $ydiff ) && ( $xdiff >= $zdiff ) ) 
		{
		  $scalefac = $xdiff;
		}
		elsif ( ( $ydiff >= $xdiff ) && ( $ydiff >= $zdiff ) ) 
		{
		  $scalefac = $ydiff;
		}
		else 
		{
		  $scalefac = $zdiff;
		}
		$scalefac = 1.0;# / $scalefac;
	}
}

sub printInputAndOptions() {
	print "Input file     : $inFilename\n";
	print "Output file    : $outFilename\n";
	print "Object name    : $object\n";
	print "Center         : <$xcen, $ycen, $zcen>\n";
	print "Scale by       : $scalefac\n";
}

sub printStatistics() {
	print "----------------\n";
	print "Vertices       : $numVerts\n";
	print "Faces          : $numFaces\n";
	print "Texture Coords : $numTexture\n";
	print "Normals        : $numNormals\n";
}

# reads vertices into $xcoords[], $ycoords[], $zcoords[]
#   where coordinates are moved and scaled according to
#   $xcen, $ycen, $zcen and $scalefac
# reads texture coords into $tx[], $ty[] 
#   where y coordinate is mirrowed
# reads normals into $nx[], $ny[], $nz[]
#   but does not normalize, see normalizeNormals()
# reads faces and establishes lookup data where
#   va_idx[], vb_idx[], vc_idx[] for vertices
#   ta_idx[], tb_idx[], tc_idx[] for texture coords
#   na_idx[], nb_idx[], nc_idx[] for normals
#   store indizes for the former arrays respectively
#   also, $face_line[] store actual face string
sub loadData {
	$numVerts = 0;
	$numFaces = 0;
	$numTexture = 0;
	$numNormals = 0;
    
    $mFValue1 = 0;
    $mFValue2 = 0;
    $mFValue3 = 0;
    
	my $objCounter = 0;
	
    $nx = 0;
    $ny = 0;
    $nz = 0;
    
    
    chdir($inFoldername);
    
	open ( INFILE, "<$inFilename" )
	  || die "Can't find file $inFilename...exiting \n";
	
	while ($line = <INFILE>) 
	{
        chop $line;
	  
    
        if ($line =~ /o\s+.*/)
        {
            $objCounter++;
        }

      
      
	  # vertices
	  if ($line =~ /v\s+.*/)
	  {
	    @tokens= split(' ', $line);
	    $x = $tokens[1] * $scalefac; #$xcen
	    $y = $tokens[2] * $scalefac;
	    $z = $tokens[3] * $scalefac;
	    $xcoords[$numVerts] = sprintf "%.3f", $x; 
        $ycoords[$numVerts] = sprintf "%.3f", $y;
        $zcoords[$numVerts] = sprintf "%.3f", $z;
	
	    $numVerts++;
	  }
	  
	  # texture coords
	  if ($line =~ /vt\s+.*/)
	  {
	    @tokens= split(' ', $line);
	    $x = $tokens[1];
	    $y = 1 - $tokens[2];
	    $tx[$numTexture] = sprintf "%.3f", $x;
        $ty[$numTexture] = sprintf "%.3f", $y;
	    
	    $numTexture++;
	  }
	  
	  #normals
	  if ($line =~ /vn\s+.*/)
	  {
	    @tokens= split(' ', $line);
	    $x = $tokens[1];
	    $y = $tokens[2];
	    $z = $tokens[3];
        $nx[$numNormals] = sprintf "%.3f", $x;
        $ny[$numNormals] = sprintf "%.3f", $y;
        $nz[$numNormals] = sprintf "%.3f", $z;
	
	    $numNormals++;
	  }
	  
	  # faces
	  if ($line =~ /f\s+([^ ]+)\s+([^ ]+)\s+([^ ]+)(\s+([^ ]+))?/) 
	  {
	  	@a = split('/', $1);
	  	@b = split('/', $2);
	  	@c = split('/', $3);
        
        if($numFaces == 0)
        {
            $mFValue1 = $a[0]-1;
            
            $mFValue2 = $a[1]-1;
            
            $mFValue3 = $a[2]-1;
        }
        
	  	$va_idx[$numFaces] = $a[0]-1-$mFValue1;
	  	$ta_idx[$numFaces] = $a[1]-1-$mFValue2;
	  	$na_idx[$numFaces] = $a[2]-1-$mFValue3;
	
	  	$vb_idx[$numFaces] = $b[0]-1-$mFValue1;
	  	$tb_idx[$numFaces] = $b[1]-1-$mFValue2;
	  	$nb_idx[$numFaces] = $b[2]-1-$mFValue3;
	
	  	$vc_idx[$numFaces] = $c[0]-1-$mFValue1;
	  	$tc_idx[$numFaces] = $c[1]-1-$mFValue2;
	  	$nc_idx[$numFaces] = $c[2]-1-$mFValue3;
	  	
	  	$face_line[$numFaces] = $line;
	  	
		$numFaces++;
		
		# ractangle => second triangle
		if($5 != "")
		{
			@d = split('/', $5);
			$va_idx[$numFaces] = $a[0]-1;
			$ta_idx[$numFaces] = $a[1]-1;
			$na_idx[$numFaces] = $a[2]-1;

			$vb_idx[$numFaces] = $d[0]-1;
			$tb_idx[$numFaces] = $d[1]-1;
			$nb_idx[$numFaces] = $d[2]-1;

			$vc_idx[$numFaces] = $c[0]-1;
			$tc_idx[$numFaces] = $c[1]-1;
			$nc_idx[$numFaces] = $c[2]-1;

			$face_line[$numFaces] = $line;

			$numFaces++;
		}
		
	  }  
	}
	
	close INFILE;
}

sub normalizeNormals {
	for ( $j = 0; $j < $numNormals; ++$j) 
	{
	 $d = sqrt ( $nx[$j]*$nx[$j] + $ny[$j]*$ny[$j] + $nz[$j]*$nz[$j] );
	  
	  if ( $d == 0 )
	  {
	    $nx[$j] = 1;
	    $ny[$j] = 0;
	    $nz[$j] = 0;
	  }
	  else
	  {
        $nx[$j] = sprintf "%.3f", ($nx[$j] / $d);
        $ny[$j] = sprintf "%.3f", ($ny[$j] / $d);
        $nz[$j] = sprintf "%.3f", ($nz[$j] / $d);
        
        if($nx[$j] == 0.000)
        {
            $nx[$j] = -0.001;
        }
        
        
        if($ny[$j] == 0.000)
        {
            $ny[$j] = -0.001;
        }
        
        
        if($nz[$j] == 0.000)
        {
            $nz[$j] = -0.001;
        }
	  }
	    
	}
}

sub fixedIndex {
    local $idx = $_[0];
    local $num = $_[1];
    
    if($idx >= 0)
    {
        $idx;
    } else {
        $num + $idx + 1;
    }
}

sub openFileAndTypeInTheBeginning
{
    if(length($outFoldername) > 0)
    {
        # changing current directory to the script resides dir
        $path = abs_path($0);
        $path = substr($path, 0, index($path,'FolderCreator.pl') );
        $pwd = `pwd`;
        chop($pwd);
        $index = index($path,$pwd);
        if( index($path,$pwd) == 0 ) {
            $length = length($pwd);
            $path = substr($path, $length+1);

            $index = index($path,'/');
            while( $index != -1){
                $nxtfol = substr($path, 0, $index);
                chdir($nxtfol) or die "Unable to change dir : $nxtfol"; 
                $path = substr($path, $index+1);
                $index = index($path,'/');
            } 
        }
        # dir changing done...

        # creation of dir starts here
        unless(chdir($outFoldername))       # If the dir available change current , unless
        {
            mkdir($outFoldername, 0755);    # Create a directory
        }
    }
    else
    {
        print "Usage : <FOLDER_NAME>\n";    
    }
    
    chdir($outFoldername);
    
    open ( OUTFILE, ">$outFilename" . "Header.b")
      || die "Can't create file $outFilename ... exiting\n";
    
    
    print OUTFILE "".($numFaces * 3)."\n";
	
    print OUTFILE "$xcen,$ycen,$zcen\n";

    close OUTFILE;
}


sub writeOutput {
    
    chdir($outFoldername);
    
    open ( PARTOUTFILE, ">$outFileNameWithoutExtension" . "PartVerts.b")
      || die "Can't create file $outFilename ... exiting\n";
    
    print "Will have verts \n";
    
	# write verts
    for( $j = 0; $j < $numFaces; $j++)
	{
		$ia = fixedIndex($va_idx[$j], $numVerts);
		$ib = fixedIndex($vb_idx[$j], $numVerts);
		$ic = fixedIndex($vc_idx[$j], $numVerts);
		
        print PARTOUTFILE pack('f<',$xcoords[$ia]);
        print PARTOUTFILE pack('f<',$ycoords[$ia]);
        print PARTOUTFILE pack('f<',$zcoords[$ia]);
        
        print PARTOUTFILE pack('f<',$xcoords[$ib]);
        print PARTOUTFILE pack('f<',$ycoords[$ib]);
        print PARTOUTFILE pack('f<',$zcoords[$ib]);
        
        print PARTOUTFILE pack('f<',$xcoords[$ic]);
        print PARTOUTFILE pack('f<',$ycoords[$ic]);
        print PARTOUTFILE pack('f<',$zcoords[$ic]);
	}
    
    close PARTOUTFILE;
    
    open ( PARTOUTFILE, ">$outFileNameWithoutExtension" . "PartNormals.b" )
      || die "Can't create file $outFilename ... exiting\n";
    
	# write normals
	if($numNormals > 0)
    {
        print "Will have normals \n";
        
        for( $j = 0; $j < $numFaces; $j++)
        {
			$ia = fixedIndex($na_idx[$j], $numNormals);
			$ib = fixedIndex($nb_idx[$j], $numNormals);
			$ic = fixedIndex($nc_idx[$j], $numNormals);
                        
            if(!$nx[$ia])
            {
                $nx[$ia] = 0;
            }
            
            if(!$ny[$ia])
            {
                $ny[$ia] = 0;
            }
            
            if(!$nz[$ia])
            {
                $nz[$ia] = 0;
            }
            
            print PARTOUTFILE pack('f<',$nx[$ia]);
            print PARTOUTFILE pack('f<',$ny[$ia]);
            print PARTOUTFILE pack('f<',$nz[$ia]);
        
            print PARTOUTFILE pack('f<',$nx[$ib]);
            print PARTOUTFILE pack('f<',$ny[$ib]);
            print PARTOUTFILE pack('f<',$nz[$ib]);
            
            print PARTOUTFILE pack('f<',$nx[$ic]);
            print PARTOUTFILE pack('f<',$ny[$ic]);
            print PARTOUTFILE pack('f<',$nz[$ic]);
        }
	}
    else
    {
        print "Will not have normals \n";
    }
	
    close PARTOUTFILE;
    
    open ( PARTOUTFILE, ">$outFileNameWithoutExtension" . "PartTextureCoords.b" )
      || die "Can't create file $outFilename ... exiting\n";
    
	# write texture coords
	if($numTexture)
    {
        print "Will have texture coords \n";
        
        for( $j = 0; $j < $numFaces; $j++)
        {
			$ia = fixedIndex($ta_idx[$j], $numTexture);
			$ib = fixedIndex($tb_idx[$j], $numTexture);
			$ic = fixedIndex($tc_idx[$j], $numTexture);
			
            
            print PARTOUTFILE pack('f<',$tx[$ia]);
            print PARTOUTFILE pack('f<',$ty[$ia]);
            
            print PARTOUTFILE pack('f<',$tx[$ib]);
            print PARTOUTFILE pack('f<',$ty[$ib]);
            
            print PARTOUTFILE pack('f<',$tx[$ic]);
            print PARTOUTFILE pack('f<',$ty[$ic]);
		}
	}
    else
    {
        print "Will not have texture coords \n";
    }
    
    close PARTOUTFILE;
}
