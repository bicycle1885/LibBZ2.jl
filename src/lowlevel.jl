# Lower-level interface to the bzip2 library.

const bzip2 = "libbz2"

# Constants
# ---------

const BZ_RUN              = Cint(0)
const BZ_FLUSH            = Cint(1)
const BZ_FINISH           = Cint(2)

const BZ_OK               = Cint(0)
const BZ_RUN_OK           = Cint(1)
const BZ_FLUSH_OK         = Cint(2)
const BZ_FINISH_OK        = Cint(3)
const BZ_STREAM_END       = Cint(4)
const BZ_SEQUENCE_ERROR   = Cint(-1)
const BZ_PARAM_ERROR      = Cint(-2)
const BZ_MEM_ERROR        = Cint(-3)
const BZ_DATA_ERROR       = Cint(-4)
const BZ_DATA_ERROR_MAGIC = Cint(-5)
const BZ_IO_ERROR         = Cint(-6)
const BZ_UNEXPECTED_EOF   = Cint(-7)
const BZ_OUTBUFF_FULL     = Cint(-8)
const BZ_CONFIG_ERROR     = Cint(-9)


# BZStream
# --------

type BZStream
    next_in::Ptr{UInt8}
    avail_in::Cuint
    total_in_lo32::Cuint
    total_in_hi32::Cuint

    next_out::Ptr{UInt8}
    avail_out::Cuint
    total_out_lo32::Cuint
    total_out_hi32::Cuint

    state::Ptr{Void}

    bzalloc::Ptr{Void}
    bzfree::Ptr{Void}
    opaque::Ptr{Void}

    function BZStream()
        bzstream = new()
        bzstream.next_in        = C_NULL
        bzstream.avail_in       = 0
        bzstream.total_in_lo32  = 0
        bzstream.total_in_hi32  = 0
        bzstream.next_out       = C_NULL
        bzstream.avail_out      = 0
        bzstream.total_out_lo32 = 0
        bzstream.total_out_hi32 = 0
        bzstream.state          = C_NULL
        bzstream.bzalloc        = C_NULL
        bzstream.bzfree         = C_NULL
        bzstream.opaque         = C_NULL
        return bzstream
    end
end

# Functions
# ---------

function version()
    return unsafe_string(ccall((:BZ2_bzlibVersion, bzip2), Ptr{UInt8}, ()))
end

function init_compress!(
        bzstream::BZStream,
        blocksize100k::Integer,
        verbosity::Integer,
        workfactor::Integer)
    return ccall(
        (:BZ2_bzCompressInit, bzip2),
        Cint,
        (Ref{BZStream}, Cint, Cint, Cint),
        bzstream, blocksize100k, verbosity, workfactor)
end

function compress!(bzstream::BZStream, action::Integer)
    return ccall(
        (:BZ2_bzCompress, bzip2),
        Cint,
        (Ref{BZStream}, Cint),
        bzstream, action)
end

function end_compress!(bzstream::BZStream)
    return ccall((:BZ2_bzCompressEnd, bzip2), Cint, (Ref{BZStream},), bzstream)
end

function init_decompress!(bzstream::BZStream, verbosity::Integer, small::Integer)
    return ccall(
        (:BZ2_bzDecompressInit, bzip2),
        Cint,
        (Ref{BZStream}, Cint, Cint),
        bzstream, verbosity, small)
end

function decompress!(bzstream::BZStream)
    return ccall((:BZ2_bzDecompress, bzip2), Cint, (Ref{BZStream},), bzstream)
end

function end_decompress!(bzstream::BZStream)
    return ccall((:BZ2_bzDecompressEnd, bzip2), Cint, (Ref{BZStream},), bzstream)
end
