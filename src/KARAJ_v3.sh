#!/bin/bash
####################################################################################################################################################
#							KARAJ:      a command-line software to automate and streamline acquiring biological data       					       #
#   						Version:    v2.0								                  					                                   #
#							About:      Developed in the BioMedical Machine Learning Lab, University of New South Wales.   					       #
#							Developer: Ali Afrasiabi                                                                                              #
####################################################################################################################################################

set -uo pipefail

#********************************* FUNCTION checkInstallation *********************************
function checkInstallation
{
    if [[ -n "${_KARAJ_CHECKED:-}" ]]; then
        return 0
    fi
    _KARAJ_CHECKED=1

    if detect_aspera; then
        is_aspera_installed="ascp found"
    else
        is_aspera_installed=""
    fi

    if command -v lynx >/dev/null 2>&1; then
        is_lynx_installed="Status: install ok installed"
    else
        is_lynx_installed=""
    fi

    if command -v efetch >/dev/null 2>&1 && command -v esearch >/dev/null 2>&1; then
        is_ncbi_installed="Status: install ok installed"
    else
        is_ncbi_installed=""
    fi

    if command -v curl >/dev/null 2>&1; then
        is_curl_installed="Status: install ok installed"
    else
        is_curl_installed=""
    fi

    local missing_extras=""
    for t in axel parallel wget bc; do
        if ! command -v "$t" >/dev/null 2>&1; then
            missing_extras+=" $t"
        fi
    done

    if [[ "${is_aspera_installed}" == "ascp found" && \
          "${is_curl_installed}" == "Status: install ok installed" && \
          "${is_ncbi_installed}" == "Status: install ok installed" && \
          "${is_lynx_installed}" == "Status: install ok installed" && \
          -z "$missing_extras" ]]; then
        echo ""
        echo "KARAJ v2.0 is ready to go."
        echo ""
    else
        echo
        echo "KARAJ failed to progress. KARAJ may not be installed properly. Please run the installer."
        echo
        exit 1
    fi
}


#********************************* FUNCTION Version *********************************
function Version
{
    echo ""
    echo "KARAJ:      a command-line software to automate and streamline acquiring biological data"
    echo "Version:    v2.0"
    echo "About:      developed in the Computational Biology Lab, Children's Cancer Institute, University of New South Wales."
    echo "Developer:  Ali Afrasiabi (a.afrasiabi@unsw.edu.au)"
    echo "Acknowledgement: Mahdieh Labani (m.labani@unsw.edu.au) contributed to the development of v1.0."
    echo "Code:       https://github.com/GTP-programmers/KARAJ"
    echo ""
}

#********************************* FUNCTION usage *********************************
function usage
{
    echo ""
    echo "Instruction: the list of operations and options that are supported by KARAJ"
    echo ""
    echo "    -l                 list of URL(s), please see examples (usage examples -u) or github for further explanation."
    echo "    -p                 list of PMCID(s), please see examples (usage examples -u) or github for further explanation."
    echo "    -o                 Output working directory."
    echo "    -t                 type of files: bam/vcf/fastq, please see examples (usage examples -u) or github for further explanation."
    echo "    -s                 obtaining supplementary data of the corresponding study/studies by specifiying value 1. default value is 0, which disables the operation."
    echo "    -f                 downloading list of PMCIDs, URLs or accession numbers by passing values 1, 2 and 3, respectively."
    echo "                       please see examples (usage examples -u) or github for further explanation."
    echo "    -i                 accession number(s): PRJNA/SRP/ERP/GSE/SRR/SRA/SRX/SRS/ERX/ERS/ERP/DRR/DRS/DRX/DRP/GSM/ENCSR/ENCSB/ENCSD/CXR/SAMN."
    echo "    -d                 default value is 0 which means downloading data for all accession numbers obtained from URL(s) or PMCID(s)."
    echo "                       by passing value 1 user can select accession numbers to download later on by the summary result."
    echo "    -m                 obtaining metadata table containing sample information and experimental design of the corresponding study."
    echo "    -h                 help."
    echo "    -u                 usage examples."
    echo "    -v                 version and about."
    echo "    -j                 number of cores."
    echo "    -n                 obtaining processed data of the corresponding study/studies by specifying value 1. default value is 0, which disables the operation."
}

#********************************* FUNCTION Example *********************************
function Example
{
    cat <<'EOF'

KARAJ usage examples
*********************************

Mode flags (one is required: -l, -p, -f, or -i)

  -p   Start from one or more PMCIDs
       karaj.sh -p PMC3737249
       karaj.sh -p PMC3737249 PMC4286305 -o /data/karaj_out

  -l   Start from one or more PMC article URLs
       karaj.sh -l https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3737249/
       karaj.sh -l https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3737249/ \
                   https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4286305/

  -i   Start from one or more accession numbers (GSE/PRJNA/SRP/ERP/SRR/...)
       karaj.sh -i GSE38676
       karaj.sh -i SRR513107 SRR513108

  -f   Start from a file in the current directory
         -f 1   reads PMCID.txt        (one PMCID per line)
         -f 2   reads ACCESSIONS.txt   (one accession per line)
         -f 3   reads URLS.txt         (one URL per line)

       echo PMC3737249 > PMCID.txt
       karaj.sh -f 1 -o /data/karaj_out

       printf "GSE38676\nSRR513107\n" > ACCESSIONS.txt
       karaj.sh -f 2

Output and resources

  -o   Output working directory (default: current directory)
       karaj.sh -i GSE38676 -o /data/karaj_out

  -j   Number of cores for parallel Aspera transfers (default: nproc - 1)
       karaj.sh -i GSE38676 -j 8

Filtering and content selection

  -t   Restrict downloads to a single file type: bam | fastq | fasta | vcf
       karaj.sh -i GSE38676 -t fastq
       karaj.sh -p PMC3737249 -t bam -o /data/karaj_out

  -d   Interactively select which accession(s) to download from the summary
         -d 0   download all (default)
         -d 1   prompt the user to choose by index from the printed summary
       karaj.sh -p PMC3737249 -d 1

  -s   Download supplementary data (xlsx, txt, tsv, zip, ...) from the article
         -s 0   skip (default)
         -s 1   download supplementary files; KARAJ exits after this step
       karaj.sh -p PMC3737249 -s 1 -o /data/karaj_out

  -m   Generate a per-study metadata table (sample names, run IDs, sample IDs)
         -m 1   write *_metadata files; KARAJ exits after this step
       karaj.sh -i GSE38676 -m 1 -o /data/karaj_out

  -n   Download processed data (e.g. count matrices) instead of / in addition
       to raw reads
         -n 0   skip (default)
         -n 1   download processed files via axel
       karaj.sh -i GSE38676 -n 1 -o /data/karaj_out

Information flags (no mode flag needed)

  -h   Print the help message
       karaj.sh -h

  -u   Print these usage examples
       karaj.sh -u

  -v   Print version and about
       karaj.sh -v

Combining flags

  Typical end-to-end run, fastq only, 8 cores, custom output:
       karaj.sh -p PMC3737249 -t fastq -j 8 -o /data/karaj_out

  Inspect first, download later:
       karaj.sh -p PMC3737249              # see the summary
       karaj.sh -i GSE38676 -t fastq       # download the one you wanted

Notes
  -l and -p accept multiple values: -p PMC1 PMC2 PMC3
  -s 1 and -m 1 are exclusive operations: KARAJ exits after completing them
  Only one mode flag (-l, -p, -f, -i) may be used per invocation

EOF
}

#********************************* FUNCTION detect_aspera *********************************
# Locate ascp binary and SSH key, checking multiple known install locations.
# Sets global ASCP_BIN and ASCP_KEY on success.
# Returns: 0 if both found, 1 otherwise.
detect_aspera()
{
    # If user has set them explicitly, respect that
    if [[ -n "${ASCP_BIN:-}" && -n "${ASCP_KEY:-}" ]]; then
        if [[ -x "$ASCP_BIN" && -f "$ASCP_KEY" ]]; then
            return 0
        fi
    fi

    # Try known ascp locations
    local candidates=(
        "$HOME/.aspera/sdk/ascp"
        "$HOME/.aspera/connect/bin/ascp"
        "$(command -v ascp 2>/dev/null)"
    )

    ASCP_BIN=""
    for c in "${candidates[@]}"; do
        if [[ -n "$c" && -x "$c" ]]; then
            if "$c" --version 2>/dev/null | grep -Eiq "ascp version|IBM Aspera"; then
                ASCP_BIN="$c"
                break
            fi
        fi
    done

    if [[ -z "$ASCP_BIN" ]]; then
        return 1
    fi

    # Try known SSH key locations (in order of preference)
    local key_candidates=(
        "$HOME/.aspera/sdk/etc/asperaweb_id_dsa.openssh"
        "$HOME/.aspera/connect/etc/asperaweb_id_dsa.openssh"
        "$(dirname "$(readlink -f "$0")")/../etc/asperaweb_id_dsa.openssh"
        "$(dirname "$(readlink -f "$0")")/asperaweb_id_dsa.openssh"
    )

    ASCP_KEY=""
    for k in "${key_candidates[@]}"; do
        if [[ -f "$k" ]]; then
            ASCP_KEY="$k"
            break
        fi
    done

    if [[ -z "$ASCP_KEY" ]]; then
        return 1
    fi

    return 0
}

#********************************* FUNCTION extract_accessions_from_url *********************************
# Fetches a single article URL once and extracts all four accession types.
# Args:   $1 = URL
#         $2 = path to file to APPEND deduped accessions to
# Output: appends one accession per line to $2
# Side effect: prints "There is no accession number..." if this paper contributed none
# Network: 1 lynx call per URL (was 5)
extract_accessions_from_url()
{
    local url="$1"
    local outfile="$2"
    local types=("GSE" "PRJNA" "ERP" "SRP")
    local dump before after Z i

    before=0
    [[ -s "$outfile" ]] && before=$(wc -l <"$outfile")

    dump=$(lynx -dump "$url" 2>/dev/null) || {
        echo "WARNING: failed to fetch $url" >&2
        return 1
    }

    for i in "${types[@]}"; do
        echo "$dump" | grep -Eo "${i}[0-9]+"
    done | sed 's/[[:space:]]//g' | sort -u >> "$outfile"

    # Re-dedupe outfile so per-PMCID counter reflects unique-across-script
    sort -u "$outfile" -o "$outfile"
    after=$(wc -l <"$outfile")

    if [[ "$before" == "$after" ]]; then
        Z=$(echo "$url" | grep -Eo "PMC[0-9]+")
        echo "There is no accession number in the text of ${Z:-$url}"
        echo ""
    fi
}

#********************************* FUNCTION fetch_pubmed_metadata *********************************
# Fetches one medline record for the given PMC URL and writes a labeled,
# human-readable summary to ${out}/${Z}/article_info.txt.
# Args:   $1 = URL of PMC article
#         $2 = path to the file containing accessions found for THIS paper
#              (one per line; pass empty/missing if not yet computed)
# Network: 1 lynx + 1 efetch per call (was 1 lynx + 4 efetch)
fetch_pubmed_metadata()
{
    local url="$1"
    local accessions_file="${2:-}"
    local pmid medline title abstract authors pmid_line Z accessions outdir outfile

    Z=$(echo "$url" | grep -Eo "PMC[0-9]+")
    if [[ -z "$Z" ]]; then
        return 0
    fi

    outdir="${out}/${Z}"
    outfile="${outdir}/article_info.txt"
    mkdir -p "$outdir"

    pmid=$(lynx -dump "$url" 2>/dev/null \
        | grep -Eo "PMID: \[.*\][0-9]+" \
        | sed 's/.*]//' \
        | head -1)

    if [[ -z "$pmid" ]]; then
        echo "WARNING: could not extract PMID from ${url}" >&2
        return 1
    fi

    medline=$(efetch -db pubmed -id "$pmid" -format medline 2>/dev/null) || {
        echo "WARNING: efetch failed for PMID ${pmid}" >&2
        return 1
    }

    title=$(echo "$medline" \
        | sed -n '/^TI  -/,/^PG  -/{ /^PG  -/!p; }' \
        | sed 's|TI  - ||' \
        | sed 's/^[[:space:]]*//' \
        | tr '\n' ' ' \
        | tr -s ' ')

    abstract=$(echo "$medline" \
        | sed -n '/^AB  -/,/^FAU -/{ /^FAU -/!p; }' \
        | sed 's|AB  - ||' \
        | sed 's/^[[:space:]]*//' \
        | grep -v '^CI  - ' \
        | tr '\n' ' ' \
        | tr -s ' ')

    authors=$(echo "$medline" \
        | sed -n '/^AU  -/,/^AD  -/{ /^AD  -/!p; }' \
        | sed 's|AU  - ||' \
        | sed 's/^[[:space:]]*//' \
        | grep -v '^AUID-' \
        | paste -sd';')

    pmid_line=$(echo "$medline" \
        | grep '^PMID-' \
        | head -1 \
        | sed 's|PMID- |PMID:|' \
        | sed 's/^[[:space:]]*//')

    accessions=""
    if [[ -n "$accessions_file" && -s "$accessions_file" ]]; then
        accessions=$(paste -sd';' "$accessions_file")
    fi

    {
        echo "URL: ${url}"
        echo "Accessions: ${accessions}"
        echo "Title: ${title}"
        echo "Authors: ${authors}"
        echo "${pmid_line}"
        echo "Abstract: ${abstract}"
    } > "$outfile"
}

#********************************* FUNCTION generate_metadata_table *********************************
# Downloads the GEO series matrix for a GSE accession and produces a
# tab-separated metadata file with columns Sample_name, RunID, SampleID.
# Args:   $1 = accession (only GSE* accepted; others skipped with a message)
# Output: writes ${out}/${B}/${B}_metadata
# Network: 1 wget per call
#********************************* FUNCTION generate_metadata_table *********************************
generate_metadata_table()
{
    local B="$1"
    local X y url series_matrix titles accessions sources

    if [[ ! "$B" =~ ^GSE[0-9]+$ ]]; then
        echo "Skipping metadata for ${B}: only GEO series (GSE) accessions are supported." >&2
        return 0
    fi

    X=$(echo "$B" | rev | cut -c4- | rev)
    y="${X}nnn"
    url="https://ftp.ncbi.nlm.nih.gov/geo/series/${y}/${B}/matrix/${B}_series_matrix.txt.gz"

    mkdir -p "${out}/${B}"

    if ! wget -q -P "${out}/${B}" "$url"; then
        echo "WARNING: failed to fetch series matrix for ${B}" >&2
        return 1
    fi

    if [[ ! -s "${out}/${B}/${B}_series_matrix.txt.gz" ]]; then
        echo "WARNING: empty series matrix for ${B}" >&2
        rm -f "${out}/${B}/${B}_series_matrix.txt.gz"
        return 1
    fi

    gunzip -f "${out}/${B}/${B}_series_matrix.txt.gz"
    series_matrix="${out}/${B}/${B}_series_matrix.txt"

    # Series matrix uses tab-separated values: column 1 is the field name,
    # columns 2..N are the per-sample values. cut -f2- drops the field name,
    # tr '\t' '\n' puts each sample on its own line.
    titles=$(grep '^!Sample_title'             "$series_matrix" | cut -f2- | tr -d '"' | tr '\t' '\n' | sed 's/ /_/g')
    accessions=$(grep '^!Sample_geo_accession' "$series_matrix" | cut -f2- | tr -d '"' | tr '\t' '\n')
    sources=$(grep '^!Sample_source_name_ch1'  "$series_matrix" | cut -f2- | tr -d '"' | tr '\t' '\n' | sed 's/ /_/g')

    {
        printf 'Sample_name\tRunID\tSampleID\n'
        paste \
            <(echo "$titles") \
            <(echo "$accessions") \
            <(echo "$sources")
    } > "${out}/${B}/${B}_metadata"

    rm -f "$series_matrix"
}

#********************************* FUNCTION print_summary_report *********************************
# Prints a human-readable summary block for one accession.
# Args:   $1 = accession
#         $2 = display index (the "1." / "2." prefix)
# Network: 1 wget + 1 esearch+efetch per GSE; 0 for non-GSE
print_summary_report()
{
    local B="$1"
    local C="$2"
    local X y url D series_matrix gds_info

    if [[ ! "$B" =~ ^GSE[0-9]+$ ]]; then
        echo "${C}. ${B}"
        echo "Direct SRA/SRR accession; GEO series matrix summary skipped."
        echo "##############################################"
        return 0
    fi

    X=$(echo "$B" | rev | cut -c4- | rev)
    y="${X}nnn"
    url="https://ftp.ncbi.nlm.nih.gov/geo/series/${y}/${B}/matrix/${B}_series_matrix.txt.gz"

    mkdir -p "${out}/${B}"
    wget -q -P "${out}/${B}" "$url"

    D=""
    if [[ -s "${out}/${B}/${B}_series_matrix.txt.gz" ]]; then
        gunzip -f "${out}/${B}/${B}_series_matrix.txt.gz"
        series_matrix="${out}/${B}/${B}_series_matrix.txt"
        D=$(grep '^!Series_overall_design' "$series_matrix" \
            | sed 's/!Series_overall_design//; s/^[[:space:]]*//; s/"//g')
    fi

    gds_info=$(esearch -db gds -query "$B" | efetch 2>/dev/null \
        | grep -E '^1\.|^2\.|Platform:' \
        | grep -v 'Series:' \
        | sed 's/2\. /Type: /; s/1\. /Description: /')

    echo "${C}. ${B}"
    echo "Overall experiment design: ${D}"
    echo "$gds_info" | grep 'Description: '
    echo "$gds_info" | grep 'Type: '
    echo "$gds_info" | grep -Eo '[0-9]+ Samples' | sed 's/^[[:space:]]*//'
    echo "##############################################"

    rm -f "${out}/${B}/${B}_series_matrix.txt"
}

#********************************* FUNCTION fetch_ena_filereport *********************************
# Queries ENA's filereport API for a single run accession and writes the
# tab-separated response to a file. Replaces ffq for the download stage.
#
# Args:   $1 = run accession (SRR/ERR/DRR)
#         $2 = output file path
# Returns: 0 if the API returned data with a real row (more than just the header),
#          1 otherwise (network error, unknown accession, no files available)
# Network: 1 curl call
fetch_ena_filereport()
{
    local acc="$1"
    local out_tsv="$2"
    local url

    url="https://www.ebi.ac.uk/ena/portal/api/filereport"
    url+="?accession=${acc}"
    url+="&result=read_run"
    url+="&fields=run_accession,fastq_ftp,fastq_md5,fastq_bytes,sra_ftp,sra_md5,sra_bytes,submitted_ftp,submitted_md5,submitted_bytes"
    url+="&format=tsv"

    if ! curl -sSL --retry 3 --max-time 60 "$url" -o "$out_tsv" 2>/dev/null; then
        return 1
    fi

    # Reject empty/header-only responses
    if [[ ! -s "$out_tsv" ]] || (( $(wc -l <"$out_tsv") < 2 )); then
        return 1
    fi

    return 0
}
#********************************* FUNCTION phase *********************************
# Print a stage transition: "[1/3] message"
phase()
{
    local step="$1"
    local total="$2"
    shift 2
    echo "[${step}/${total}] $*"
}

#********************************* FUNCTION substep *********************************
# Print a per-iteration progress line: "  [3/12] SRR8556723... done"
# Usage: substep <i> <n> <label> [status]
substep()
{
    local i="$1"
    local n="$2"
    local label="$3"
    local status="${4:-}"
    if [[ -n "$status" ]]; then
        echo "  [${i}/${n}] ${label}... ${status}"
    else
        echo "  [${i}/${n}] ${label}..."
    fi
}

#********************************* FUNCTION verify_md5 *********************************
# Compare a file's MD5 against an expected value.
# Args:   $1 = file path
#         $2 = expected MD5 (lowercase hex)
# Returns: 0 if match, 1 if mismatch or file missing
verify_md5()
{
    local file="$1"
    local expected="$2"
    local actual

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    actual=$(md5sum "$file" 2>/dev/null | awk '{print $1}')

    if [[ "$actual" == "$expected" ]]; then
        return 0
    else
        return 1
    fi
}

#********************************* FUNCTION resolve_accession_to_gse *********************************
# For a single non-GSE accession (ERP/PRJN/SRP/PRJNA), attempt to find a
# corresponding GEO series (GSE) accession via SRA. On success, prints the
# resolved GSE on stdout. On failure, prints nothing.
#
# Args:   $1 = accession
# Output (stdout): one GSE per line on success, empty on failure
# Network: 1-2 esearch+efetch calls
resolve_accession_to_gse()
{
    local acc="$1"
    local result=""

    # GSEs and SRR-style run accessions don't need conversion
    if [[ "$acc" =~ ^GSE[0-9]+$ ]] || [[ "$acc" =~ ^(SRR|ERR|DRR)[0-9]+$ ]]; then
        echo "$acc"
        return 0
    fi

    case "$acc" in
        ERP*|SRP*)
            # ERP/SRP → GSE via the GEO datasets database
            result=$(esearch -db gds -query "$acc" 2>/dev/null \
                | efetch -format runinfo 2>/dev/null \
                | grep 'Accession:' \
                | grep -Eo "GSE[0-9]+" \
                | sort -u)
            ;;
        PRJN*|PRJNA*)
            # PRJN/PRJNA → SRP first, then SRP → GSE
            local srp
            srp=$(esearch -db sra -query "$acc" 2>/dev/null \
                | efetch -format runinfo 2>/dev/null \
                | awk -F',' 'NR>1 {print $21}' \
                | sort -u \
                | head -1)

            if [[ -n "$srp" ]]; then
                result=$(esearch -db gds -query "$srp" 2>/dev/null \
                    | efetch -format runinfo 2>/dev/null \
                    | grep 'Accession:' \
                    | grep -Eo "GSE[0-9]+" \
                    | sort -u)
            fi
            ;;
        *)
            # Unknown prefix — return as-is, let summary handle it
            echo "$acc"
            return 0
            ;;
    esac

    # If we got at least one GSE, print all of them. Otherwise print nothing
    # (caller will keep the original accession).
    if [[ -n "$result" ]]; then
        echo "$result"
        return 0
    else
        return 1
    fi
}

#********************************* FUNCTION getopts-extra *********************************
function getopts-extra()
{
    OPTARG=( "$OPTARG" )   # reset; preserve the value getopts already captured
    declare i=1
    while [[ ${OPTIND} -le $# && ${!OPTIND:0:1} != '-' ]]; do
        OPTARG[i]=${!OPTIND}
        let i++ OPTIND++
    done
}

## specifying the options
link=()
PMCID=()
ID=()
file=""
Output=""
down=""
type=""
supp=""
meta=""
core=""
processed=""

while getopts ":l:p:d:o:t:s:f:i:m:uhvj:n:" opt; do
    case ${opt} in
        l) getopts-extra "$@"; link=( "${OPTARG[@]}" ) ;;
        p) getopts-extra "$@"; PMCID=( "${OPTARG[@]}" ) ;;
        d) down="$OPTARG" ;;
        o) Output="$OPTARG" ;;
        t) type="$OPTARG" ;;
        s) supp="$OPTARG" ;;
        f) file="$OPTARG" ;;
        i) getopts-extra "$@"; ID=( "${OPTARG[@]}" ) ;;
        m) meta="$OPTARG" ;;
        u) Example; exit 0 ;;
        h) usage;   exit 0 ;;
        v) Version;   exit 0 ;;
        j) core="$OPTARG" ;;
        n) processed="$OPTARG" ;;
        \?) echo "Invalid option, please see the Help using -h option:" >&2; exit 0 ;;
        :)  printf "Argument missing from -%s option\n" "$OPTARG"; exit 0 ;;
    esac
done
shift $((OPTIND - 1))

## show help when no arguments are provided
if [[ $# -eq 0 && -z "${link[*]}" && -z "${PMCID[*]}" && -z "$file" && -z "${ID[*]}" ]]; then
    usage
    exit 1
fi

## reject unexpected positional arguments
if [[ $# -gt 0 ]]; then
    echo "Error: unexpected argument(s): $*" >&2
    echo "" >&2
    echo "Use -h for help or -u for usage examples." >&2
    exit 1
fi

## exactly one of -l / -p / -f / -i must be set
n_modes=0
[[ -n "${link[*]}"  ]] && (( n_modes++ ))
[[ -n "${PMCID[*]}" ]] && (( n_modes++ ))
[[ -n "$file"       ]] && (( n_modes++ ))
[[ -n "${ID[*]}"    ]] && (( n_modes++ ))

if (( n_modes > 1 )); then
    echo "Cannot use two of these flags together: -p, -l, -i, or -f." >&2
    exit 0
fi

## now that we know we'll actually do work, validate the environment
checkInstallation

## specifying output directory
if [[ -n "$Output" ]]; then
    echo "*******************************"
    echo "The specified output directory is:"
    echo "$Output"
    echo "*******************************"
    echo ""

    mkdir -p "$Output" || { echo "ERROR: cannot create output directory: $Output" >&2; exit 1; }
    cd "$Output"       || { echo "ERROR: cannot access output directory: $Output" >&2; exit 1; }
    out="$PWD"
else
    echo "*******************************"
    echo "Output directory is not specified"
    echo "the current working directory \"$PWD\" will be used as output directory"
    echo "*******************************"
    echo ""
    out="$PWD"
fi

## making URL(s) from PMCID(s)
if [[ -v PMCID ]]; then
    : >PMCIDlist
    for j in "${!PMCID[@]}"; do
        if [[ ! "${PMCID[j]}" =~ ^PMC[0-9]+$ ]]; then
            echo "WARNING: '${PMCID[j]}' does not look like a PMCID (expected PMC followed by digits); proceeding anyway." >&2
        fi
        echo "https://www.ncbi.nlm.nih.gov/pmc/articles/${PMCID[j]}/" >>PMCIDlist
    done
    sort -u PMCIDlist -o PMCIDlist

    ## obtaining supplementary tables using PMCID
    if [[ "${supp:-0}" == '1' ]]; then
        while IFS= read -r p; do
            [[ -z "$p" ]] && continue

            Z=$(echo "$p" | grep -Eo "PMC[0-9]+" | sort -u)
            [[ -z "$Z" ]] && { echo "WARNING: cannot extract PMCID from $p; skipping." >&2; continue; }

            mkdir -p "${out}/${Z}"

            lynx -dump -listonly "$p" \
                | awk '{print $2}' \
                | grep -Ei '\.(xlsx?|tsv|txt|zip)([?#].*)?$' \
                | grep -v '/Article/' \
                | sort -u >"${out}/${Z}/supp_urls.txt"

            if [[ ! -s "${out}/${Z}/supp_urls.txt" ]]; then
                echo "No supplementary files found for ${Z}." >&2
                rm -f "${out}/${Z}/supp_urls.txt"
                continue
            fi

            while IFS= read -r s; do
                [[ -z "$s" ]] && continue
                fname=$(basename "${s%%[?#]*}")
                if [[ -s "${out}/${Z}/${fname}" ]]; then
                    echo "Already present, skipping: ${fname}"
                    continue
                fi
                axel -n 4 "$s" -o "${out}/${Z}"
            done <"${out}/${Z}/supp_urls.txt"

            rm -f "${out}/${Z}/supp_urls.txt"
        done <PMCIDlist

        exit 0
    fi

    ## searching for accession numbers and capturing per-paper article info
    : >list
    while IFS= read -r url; do
        [[ -z "$url" ]] && continue

        Z=$(echo "$url" | grep -Eo "PMC[0-9]+")
        [[ -z "$Z" ]] && continue
        mkdir -p "${out}/${Z}"
        paper_acc_file="${out}/${Z}/_accessions.tmp"
        : >"$paper_acc_file"

        extract_accessions_from_url "$url" "$paper_acc_file"
        cat "$paper_acc_file" >>list

        fetch_pubmed_metadata "$url" "$paper_acc_file"

        rm -f "$paper_acc_file"
    done <PMCIDlist

    sort -u list -o list

    if [[ ! -s list ]]; then
        exit 0
    fi

    mapfile -t lines <list

    ## generating metadata
    if [[ "${meta:-0}" == '1' ]]; then
        for B in "${lines[@]}"; do
            generate_metadata_table "$B"
        done
        exit 0
    fi

    ## generating summary report
    echo "summary report:"
    echo ""
    for idx in "${!lines[@]}"; do
        print_summary_report "${lines[idx]}" "$((idx+1))"
    done

    echo ""
    echo "##############################################"
    echo "$(cat list) specified to download"
    echo "##############################################"
    echo ""
    cp list list1
fi
	
## fetching content for user-specified URL(s)
if [[ -v link ]]; then
    : >PMCIDlist
    for j in "${!link[@]}"; do
        echo "${link[j]}" >>PMCIDlist
    done
    sort -u PMCIDlist -o PMCIDlist
    cp PMCIDlist list1

    ## obtaining supplementary tables for each URL
    if [[ "${supp:-0}" == '1' ]]; then
        while IFS= read -r p; do
            [[ -z "$p" ]] && continue

            Z=$(echo "$p" | grep -Eo "PMC[0-9]+" | sort -u)
            [[ -z "$Z" ]] && { echo "WARNING: cannot extract PMCID from $p; skipping." >&2; continue; }

            mkdir -p "${out}/${Z}"

            lynx -dump -listonly "$p" \
                | awk '{print $2}' \
                | grep -Ei '\.(xlsx?|tsv|txt|zip)([?#].*)?$' \
                | grep -v '/Article/' \
                | sort -u >"${out}/${Z}/supp_urls.txt"

            if [[ ! -s "${out}/${Z}/supp_urls.txt" ]]; then
                echo "No supplementary files found for ${Z}." >&2
                rm -f "${out}/${Z}/supp_urls.txt"
                continue
            fi

            while IFS= read -r s; do
                [[ -z "$s" ]] && continue
                fname=$(basename "${s%%[?#]*}")
                if [[ -s "${out}/${Z}/${fname}" ]]; then
                    echo "Already present, skipping: ${fname}"
                    continue
                fi
                axel -n 4 "$s" -o "${out}/${Z}"
            done <"${out}/${Z}/supp_urls.txt"

            rm -f "${out}/${Z}/supp_urls.txt"
        done <PMCIDlist

        exit 0
    fi

    ## searching for accession numbers and capturing per-paper article info
    : >list
    while IFS= read -r url; do
        [[ -z "$url" ]] && continue

        Z=$(echo "$url" | grep -Eo "PMC[0-9]+")
        [[ -z "$Z" ]] && continue
        mkdir -p "${out}/${Z}"
        paper_acc_file="${out}/${Z}/_accessions.tmp"
        : >"$paper_acc_file"

        extract_accessions_from_url "$url" "$paper_acc_file"
        cat "$paper_acc_file" >>list

        fetch_pubmed_metadata "$url" "$paper_acc_file"

        rm -f "$paper_acc_file"
    done <PMCIDlist

    sort -u list -o list

    if [[ ! -s list ]]; then
        exit 0
    fi

    mapfile -t lines <list

    ## generating metadata
    if [[ "${meta:-0}" == '1' ]]; then
        for B in "${lines[@]}"; do
            generate_metadata_table "$B"
        done
        exit 0
    fi

    ## generating summary report
    echo "summary report:"
    echo ""
    for idx in "${!lines[@]}"; do
        print_summary_report "${lines[idx]}" "$((idx+1))"
    done

    echo ""
    echo "##############################################"
    echo "$(cat list) specified to download"
    echo "##############################################"
    echo ""
    cp list list1
fi

## searching for different types of accession numbers in the text of articles using list of PMCIDs, accession numbers or URLs that are specified by user
if [[ -v file ]];
	then
if [[ "$file" == '1' ]]; then
            ## locate PMCID.txt in PWD or $out
            if [[ -f PMCID.txt ]]; then
                pmcid_file="PMCID.txt"
            elif [[ -f "${out}/PMCID.txt" ]]; then
                pmcid_file="${out}/PMCID.txt"
            else
                echo "ERROR: PMCID.txt not found in current directory or in ${out}" >&2
                exit 1
            fi

            : >PMCIDlist
            while IFS= read -r pmcid || [[ -n "$pmcid" ]]; do
                [[ -z "$pmcid" ]] && continue
                if [[ ! "$pmcid" =~ ^PMC[0-9]+$ ]]; then
                    echo "WARNING: '${pmcid}' does not look like a PMCID; proceeding anyway." >&2
                fi
                echo "https://www.ncbi.nlm.nih.gov/pmc/articles/${pmcid}/" >>PMCIDlist
            done <"$pmcid_file"

            sort -u PMCIDlist -o PMCIDlist

            ## obtaining supplementary tables for each PMCID
            if [[ "${supp:-0}" == '1' ]]; then
                while IFS= read -r p; do
                    [[ -z "$p" ]] && continue

                    Z=$(echo "$p" | grep -Eo "PMC[0-9]+" | sort -u)
                    [[ -z "$Z" ]] && { echo "WARNING: cannot extract PMCID from $p; skipping." >&2; continue; }

                    mkdir -p "${out}/${Z}"

                    lynx -dump -listonly "$p" \
                        | awk '{print $2}' \
                        | grep -Ei '\.(xlsx?|tsv|txt|zip)([?#].*)?$' \
                        | grep -v '/Article/' \
                        | sort -u >"${out}/${Z}/supp_urls.txt"

                    if [[ ! -s "${out}/${Z}/supp_urls.txt" ]]; then
                        echo "No supplementary files found for ${Z}." >&2
                        rm -f "${out}/${Z}/supp_urls.txt"
                        continue
                    fi

                    while IFS= read -r s; do
                        [[ -z "$s" ]] && continue
                        fname=$(basename "${s%%[?#]*}")
                        if [[ -s "${out}/${Z}/${fname}" ]]; then
                            echo "Already present, skipping: ${fname}"
                            continue
                        fi
                        axel -n 4 "$s" -o "${out}/${Z}"
                    done <"${out}/${Z}/supp_urls.txt"

                    rm -f "${out}/${Z}/supp_urls.txt"
                done <PMCIDlist

                exit 0
            fi

            ## searching for accession numbers and capturing per-paper article info
            : >list
            while IFS= read -r url; do
                [[ -z "$url" ]] && continue

                Z=$(echo "$url" | grep -Eo "PMC[0-9]+")
                [[ -z "$Z" ]] && continue
                mkdir -p "${out}/${Z}"
                paper_acc_file="${out}/${Z}/_accessions.tmp"
                : >"$paper_acc_file"

                extract_accessions_from_url "$url" "$paper_acc_file"
                cat "$paper_acc_file" >>list

                fetch_pubmed_metadata "$url" "$paper_acc_file"

                rm -f "$paper_acc_file"
            done <PMCIDlist

            sort -u list -o list

            if [[ ! -s list ]]; then
                exit 0
            fi

            mapfile -t lines <list

            ## generating metadata
            if [[ "${meta:-0}" == '1' ]]; then
                for B in "${lines[@]}"; do
                    generate_metadata_table "$B"
                done
                exit 0
            fi

            ## generating summary report
            echo "summary report:"
            echo ""
            for idx in "${!lines[@]}"; do
                print_summary_report "${lines[idx]}" "$((idx+1))"
            done

            echo ""
            echo "##############################################"
            echo "$(cat list) specified to download"
            echo "##############################################"
            echo ""
            cp list list1
elif [[ "$file" == '2' ]]; then
    ## locate ACCESSIONS.txt in PWD or $out
    if [[ -f ACCESSIONS.txt ]]; then
        accessions_file="ACCESSIONS.txt"
    elif [[ -f "${out}/ACCESSIONS.txt" ]]; then
        accessions_file="${out}/ACCESSIONS.txt"
    else
        echo "ERROR: ACCESSIONS.txt not found in current directory or in ${out}" >&2
        exit 1
    fi

    : >list1
    while IFS= read -r acc || [[ -n "$acc" ]]; do
        [[ -z "$acc" ]] && continue
        echo "$acc" >>list1
    done <"$accessions_file"

    sort -u list1 -o list1

    ## resolve any non-GSE study accessions (ERP/PRJN/SRP/PRJNA) to GSEs
    new_list=$(while IFS= read -r acc; do
        [[ -z "$acc" ]] && continue
        if resolved=$(resolve_accession_to_gse "$acc"); then
            echo "$resolved"
        else
            echo "$acc"
        fi
    done <list1)
    echo "$new_list" | sort -u >list1
    cp list1 list

    if [[ ! -s list ]]; then
        exit 0
    fi

    mapfile -t lines <list

    ## generating metadata
    if [[ "${meta:-0}" == '1' ]]; then
        for B in "${lines[@]}"; do
            generate_metadata_table "$B"
        done
        exit 0
    fi

    ## generating summary report
    echo "summary report:"
    echo ""
    for idx in "${!lines[@]}"; do
        print_summary_report "${lines[idx]}" "$((idx+1))"
    done

    echo ""
    echo "##############################################"
    echo "$(cat list) specified to download"
    echo "##############################################"
    echo ""
	echo "##############################################" 
	echo ""
	
		
elif [[ "$file" == '3' ]]; then
            ## locate URLS.txt in PWD or $out
            if [[ -f URLS.txt ]]; then
                urls_file="URLS.txt"
            elif [[ -f "${out}/URLS.txt" ]]; then
                urls_file="${out}/URLS.txt"
            else
                echo "ERROR: URLS.txt not found in current directory or in ${out}" >&2
                exit 1
            fi

            : >PMCIDlist
            while IFS= read -r url || [[ -n "$url" ]]; do
                [[ -z "$url" ]] && continue
                echo "$url" >>PMCIDlist
            done <"$urls_file"

            sort -u PMCIDlist -o PMCIDlist
            cp PMCIDlist list1

            ## obtaining supplementary tables for each URL
            if [[ "${supp:-0}" == '1' ]]; then
                while IFS= read -r p; do
                    [[ -z "$p" ]] && continue

                    Z=$(echo "$p" | grep -Eo "PMC[0-9]+" | sort -u)
                    [[ -z "$Z" ]] && { echo "WARNING: cannot extract PMCID from $p; skipping." >&2; continue; }

                    mkdir -p "${out}/${Z}"

                    lynx -dump -listonly "$p" \
                        | awk '{print $2}' \
                        | grep -Ei '\.(xlsx?|tsv|txt|zip)([?#].*)?$' \
                        | grep -v '/Article/' \
                        | sort -u >"${out}/${Z}/supp_urls.txt"

                    if [[ ! -s "${out}/${Z}/supp_urls.txt" ]]; then
                        echo "No supplementary files found for ${Z}." >&2
                        rm -f "${out}/${Z}/supp_urls.txt"
                        continue
                    fi

                    while IFS= read -r s; do
                        [[ -z "$s" ]] && continue
                        fname=$(basename "${s%%[?#]*}")
                        if [[ -s "${out}/${Z}/${fname}" ]]; then
                            echo "Already present, skipping: ${fname}"
                            continue
                        fi
                        axel -n 4 "$s" -o "${out}/${Z}"
                    done <"${out}/${Z}/supp_urls.txt"

                    rm -f "${out}/${Z}/supp_urls.txt"
                done <PMCIDlist

                exit 0
            fi

            ## searching for accession numbers and capturing per-paper article info
            : >list
            while IFS= read -r url; do
                [[ -z "$url" ]] && continue

                Z=$(echo "$url" | grep -Eo "PMC[0-9]+")
                [[ -z "$Z" ]] && continue
                mkdir -p "${out}/${Z}"
                paper_acc_file="${out}/${Z}/_accessions.tmp"
                : >"$paper_acc_file"

                extract_accessions_from_url "$url" "$paper_acc_file"
                cat "$paper_acc_file" >>list

                fetch_pubmed_metadata "$url" "$paper_acc_file"

                rm -f "$paper_acc_file"
            done <PMCIDlist

            sort -u list -o list

            if [[ ! -s list ]]; then
                exit 0
            fi

            mapfile -t lines <list

            ## generating metadata
            if [[ "${meta:-0}" == '1' ]]; then
                for B in "${lines[@]}"; do
                    generate_metadata_table "$B"
                done
                exit 0
            fi

            ## generating summary report
            echo "summary report:"
            echo ""
            for idx in "${!lines[@]}"; do
                print_summary_report "${lines[idx]}" "$((idx+1))"
            done

            echo ""
            echo "##############################################"
            echo "$(cat list) specified to download"
            echo "##############################################"
            echo ""
            cp list list1
   fi
else
  echo ""
fi 


## downloading sequence data using a list of accession numbers
## downloading sequence data using a list of accession numbers
if [[ -v ID ]]; then
    : >list1
    for j in "${!ID[@]}"; do
        echo "${ID[j]}" >>list1
    done
    sort -u list1 -o list1

    ## resolve any non-GSE study accessions (ERP/PRJN/SRP/PRJNA) to GSEs
    new_list=$(while IFS= read -r acc; do
        [[ -z "$acc" ]] && continue
        if resolved=$(resolve_accession_to_gse "$acc"); then
            echo "$resolved"
        else
            echo "$acc"
        fi
    done <list1)
    echo "$new_list" | sort -u >list1
    cp list1 list

    if [[ ! -s list ]]; then
        exit 0
    fi

    mapfile -t lines <list

    ## generating metadata
    if [[ "${meta:-0}" == '1' ]]; then
        for B in "${lines[@]}"; do
            generate_metadata_table "$B"
        done
        exit 0
    fi

    ## generating summary report
    echo "summary report:"
    echo ""
    for idx in "${!lines[@]}"; do
        print_summary_report "${lines[idx]}" "$((idx+1))"
    done

    echo ""
    echo "##############################################"
    echo "$(cat list) specified to download"
    echo "##############################################"
    echo ""
fi

## selecting specific accession number(s) to download 
if [[ -v down ]];
	then
		if [[ $down == '1' ]];
		then
			echo "Enter the number of accession codes that you want to download: "  
			read n
			i=1 
			while [[ $i -le $n ]]
			do
				echo "Enter the number of accession: "  
				read number 
				echo $number >> list2
				i=$(($i+1))
			done
	
		mapfile lines < list1	
		for p in $(cat list2);do
			for idx in "${!lines[@]}";do
			
				B=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $2}')
				C=$(printf "%5d %s" $((idx+1)) "${lines[idx]}"| awk '{print $1}')
				if [[ $p == $C ]];then
				
				echo $B >> list1
				
				fi
		
				echo "##############################################" 
				echo ""
				echo "##############################################" 
				echo "$list1" "selected to download"
				echo "##############################################" 
				echo ""
				done
				done
		fi
fi

## Generating the list of downloads
## Resolve non-GSE study accessions (ERP/PRJN/SRP/PRJNA) to GSEs where possible
if [[ -s list1 ]]; then
    new_list=$(while IFS= read -r acc; do
        [[ -z "$acc" ]] && continue
        if resolved=$(resolve_accession_to_gse "$acc"); then
            echo "$resolved"
        else
            echo "$acc"
        fi
    done <list1)
    echo "$new_list" | sort -u >list1
fi


phase 1 6 "Resolving accessions to runs..."

## Resolve study/sample/GEO accessions to run accessions before download
if [[ -s list ]]; then
    tmp_run_list=$(mktemp)

    while IFS= read -r acc; do
        [[ -z "$acc" ]] && continue

        if [[ "$acc" =~ ^(SRR|ERR|DRR)[0-9]+$ ]]; then
            echo "$acc" >>"$tmp_run_list"
            continue
        fi

        run_hits=$(esearch -db sra -query "$acc" 2>/dev/null \
            | efetch -format runinfo 2>/dev/null \
            | awk -F',' 'NR>1 && $1 ~ /^(SRR|ERR|DRR)[0-9]+$/ {print $1}' | sort -u)

        if [[ -n "$run_hits" ]]; then
            echo "$run_hits" >>"$tmp_run_list"
            continue
        fi

        if [[ "$acc" =~ ^GSE[0-9]+$ ]]; then
            gse_prefix=$(echo "$acc" | rev | cut -c4- | rev)
            gse_dir="${gse_prefix}nnn"
            matrix_url="https://ftp.ncbi.nlm.nih.gov/geo/series/${gse_dir}/${acc}/matrix/${acc}_series_matrix.txt.gz"

            gsm_hits=$(wget -q -O - "$matrix_url" 2>/dev/null | gzip -dc 2>/dev/null \
                | awk -F'\t' '/^!Sample_geo_accession/ {for (i=2; i<=NF; i++) {gsub(/"/, "", $i); print $i}}')

            gse_run_hits=""
            while IFS= read -r gsm; do
                [[ -z "$gsm" ]] && continue
                gsm_runs=$(esearch -db sra -query "$gsm" 2>/dev/null \
                    | efetch -format runinfo 2>/dev/null \
                    | awk -F',' 'NR>1 && $1 ~ /^(SRR|ERR|DRR)[0-9]+$/ {print $1}' | sort -u)
                if [[ -n "$gsm_runs" ]]; then
                    gse_run_hits="${gse_run_hits}"$'\n'"${gsm_runs}"
                fi
            done <<<"$gsm_hits"

            if [[ -n "$gse_run_hits" ]]; then
                echo "$gse_run_hits" >>"$tmp_run_list"
            else
                echo "$acc" >>"$tmp_run_list"
            fi
        else
            echo "$acc" >>"$tmp_run_list"
        fi
    done <list

    sort -u "$tmp_run_list" | sed '/^$/d' >list
    cp list list1
    rm -f "$tmp_run_list"

    echo "Resolved download accession(s):"
    cat list
    echo ""
fi

phase 2 6 "Fetching ENA file records..."

## Per-accession: fetch ENA filereport TSV (replaces ffq --ftp)
fetch_total=$(wc -l <list)
fetch_i=0
for j in $(cat list); do
    fetch_i=$((fetch_i + 1))
    mkdir -p "${out}/$j"

    if ! fetch_ena_filereport "$j" "${out}/$j/check$j.tsv"; then
        substep "$fetch_i" "$fetch_total" "$j" "no record found"
        cat list | grep -v "$j" | sort | uniq > tmp && mv tmp list
        cp list list1
        rm -rf "${out}/$j" 2>/dev/null
        continue
    fi
    substep "$fetch_i" "$fetch_total" "$j" "done"
done

## search and download processed data (-n 1)
if [[ -v processed && "$processed" == '1' ]]; then
    echo "WARNING: -n 1 (processed data download) is not currently supported via ENA." >&2
    echo "         Use -s 1 to fetch supplementary files from the article instead." >&2
fi

phase 3 6 "Disk space check..."
echo ""

for j in $(cat list); do
    Dirsize=$(df -Ph "$out" | tail -1 | awk '{print $4}' | sed 's/G//g')
    URLsize=$(awk -F'\t' 'NR>1 {
        split($4, sizes, ";"); for (k in sizes) total += sizes[k]+0
        split($7, sizes, ";"); for (k in sizes) total += sizes[k]+0
        split($10, sizes, ";"); for (k in sizes) total += sizes[k]+0
    } END {printf "%.2f", total/1024/1024/1024}' "${out}/$j/check$j.tsv")

    if (( $(echo "${Dirsize} > ${URLsize}" | bc -l) )); then
        echo
        echo ------------------------------------------------------------------
        echo there is "${Dirsize}" GB space available in "${out}"
        echo "$j" size is "${URLsize}" GB
        echo There is adequate space in "${out}" to download all specified files.
        echo ------------------------------------------------------------------
        echo
    else
        echo
        echo ---------------------------------------------------------------------------------------------------
        echo there is "${Dirsize}" GB space available in "${out}"
        echo "total size of sequence data for below accession number(s)"
        echo "$(cat list)"
        echo is "${URLsize}" GB
        echo  "${out}" does not have enough space for all files you aim to download. Please change the directory.
        echo ---------------------------------------------------------------------------------------------------
        echo
        rm -f list list1 PMCIDlist
        exit 0
    fi
done

phase 4 6 "Building Aspera URL list..."

extract_urls_for_type() {
    local tsv="$1"
    local want_type="$2"
    local col=""

    case "$want_type" in
        fastq)              col=2
;;
        bam|fasta|vcf)      col=8 ;;
        sra|"")             col=2 ;;
        *)                  col=2 ;;
    esac

    awk -F'\t' -v c="$col" 'NR>1 && $c != "" {
        n = split($c, urls, ";")
        for (k=1; k<=n; k++) print urls[k]
    }' "$tsv" | grep -v '^$' | sed 's#^ftp\.sra\.ebi\.ac\.uk/#era-fasp@fasp.sra.ebi.ac.uk:/#'
}

if [[ -v type && -n "$type" ]]; then
    echo "you select the type $type"
    case "$type" in
        bam|fastq|fasta|vcf)
            for j in $(cat list1); do
                extract_urls_for_type "${out}/$j/check$j.tsv" "$type" >"${out}/$j/urls$j.txt"
            done
            ;;
        *)
            echo "WARNING: unknown -t value '$type'; downloading default fastq URLs." >&2
            for j in $(cat list1); do
                extract_urls_for_type "${out}/$j/check$j.tsv" fastq >"${out}/$j/urls$j.txt"
            done
            ;;
    esac
else
    for j in $(cat list1); do
        urls=$(extract_urls_for_type "${out}/$j/check$j.tsv" fastq)
        [[ -z "$urls" ]] && urls=$(extract_urls_for_type "${out}/$j/check$j.tsv" bam)
        [[ -z "$urls" ]] && urls=$(awk -F'\t' 'NR>1 && $5 != "" {n=split($5, u, ";"); for (k=1; k<=n; k++) print u[k]}' "${out}/$j/check$j.tsv" \
            | grep -v '^$' | sed 's#^ftp\.sra\.ebi\.ac\.uk/#era-fasp@fasp.sra.ebi.ac.uk:/#')
        echo "$urls" >"${out}/$j/urls$j.txt"
    done
fi
phase 5 6 "Downloading via Aspera..."

if ! detect_aspera; then
    echo "ERROR: Aspera installation not found." >&2
    echo "" >&2
    echo "KARAJ needs the IBM Aspera SDK or Aspera Connect installed at one of:" >&2
    echo "  - \$HOME/.aspera/sdk/ascp" >&2
    echo "  - \$HOME/.aspera/connect/bin/ascp" >&2
    echo "" >&2
    echo "Install via the IBM Aspera CLI gem (Ruby):" >&2
    echo "  gem install aspera-cli && ascli config transferd install" >&2
    echo "" >&2
    echo "Or via the standalone Aspera Connect installer:" >&2
    echo "  https://www.ibm.com/aspera/connect/" >&2
    echo "" >&2
    echo "If you have ascp but the SSH key is missing, KARAJ ships a copy at" >&2
    echo "etc/asperaweb_id_dsa.openssh — re-clone the repo or download the key" >&2
    echo "from https://github.com/your-org/KARAJ/raw/main/etc/asperaweb_id_dsa.openssh" >&2
    echo "" >&2
    echo "You can also override detection via env vars:" >&2
    echo "  export ASCP_BIN=/path/to/ascp" >&2
    echo "  export ASCP_KEY=/path/to/asperaweb_id_dsa.openssh" >&2
    exit 1
fi

if ! command -v parallel >/dev/null 2>&1; then
    echo "ERROR: GNU parallel is not installed."
    echo "Install it with: sudo apt install parallel -y"
    exit 1
fi

if [[ ! -f list1 ]]; then
    echo "ERROR: list1 was not found."
    exit 1
fi

if [[ -v core && -n "$core" ]]; then
    k="$core"
else
    k=$(nproc)
    k=$((k - 1))
    if [[ "$k" -lt 1 ]]; then
        k=1
    fi
fi

echo "${k} cores are using"
echo "Using ascp: $ASCP_BIN"
echo "Using Aspera key: $ASCP_KEY"
echo ""

SECONDS=0
start=$SECONDS

dl_total=$(grep -c . list1)
dl_i=0

while IFS= read -r w; do
    [[ -z "$w" ]] && continue

    dl_i=$((dl_i + 1))

    URL_FILE="${out}/${w}/urls${w}.txt"

    if [[ ! -f "$URL_FILE" ]]; then
        substep "$dl_i" "$dl_total" "$w" "URL list missing — skipping"
        continue
    fi

    if [[ ! -s "$URL_FILE" ]]; then
        substep "$dl_i" "$dl_total" "$w" "URL list empty — skipping"
        continue
    fi

    substep "$dl_i" "$dl_total" "$w" "downloading"

    parallel -j "$k" -- "$ASCP_BIN" -QT -l 300m --retry-timeout=1800 \
        -P33001 -i "$ASCP_KEY" {} "${out}/${w}" \
        < "$URL_FILE"

    if [[ $? -ne 0 ]]; then
        substep "$dl_i" "$dl_total" "$w" "FAILED"
        exit 1
    fi

    substep "$dl_i" "$dl_total" "$w" "completed"
done < list1

echo ""

## verify MD5 checksums for each downloaded file
phase 6 6 "Verifying MD5 checksums..."

vf_total=$(grep -c . list1)
vf_i=0

while IFS= read -r w; do
    [[ -z "$w" ]] && continue

    vf_i=$((vf_i + 1))
    tsv="${out}/${w}/check${w}.tsv"

    if [[ ! -s "$tsv" ]]; then
        substep "$vf_i" "$vf_total" "$w" "no TSV — skipping verification"
        continue
    fi

    ## Check fastq, sra, and submitted columns for MD5+filename pairs
    ## Columns: 2=fastq_ftp 3=fastq_md5  5=sra_ftp 6=sra_md5  8=submitted_ftp 9=submitted_md5
    bad_count=0
    file_count=0

    while IFS=$'\t' read -r ftp_url expected_md5; do
        [[ -z "$ftp_url" || -z "$expected_md5" ]] && continue

        ## Each cell may contain multiple semicolon-separated entries
        IFS=';' read -ra urls  <<< "$ftp_url"
        IFS=';' read -ra md5s  <<< "$expected_md5"

        for idx in "${!urls[@]}"; do
            file_url="${urls[$idx]}"
            file_md5="${md5s[$idx]:-}"
            [[ -z "$file_url" || -z "$file_md5" ]] && continue

            file_name=$(basename "$file_url")
            file_path="${out}/${w}/${file_name}"

            file_count=$((file_count + 1))

            if [[ ! -f "$file_path" ]]; then
                continue
            fi

            if ! verify_md5 "$file_path" "$file_md5"; then
                echo "    MD5 MISMATCH: ${file_name} — deleting"
                rm -f "$file_path"
                bad_count=$((bad_count + 1))
            fi
        done
    done < <(awk -F'\t' 'NR>1 {
        if ($2 != "" && $3 != "") print $2 "\t" $3
        if ($5 != "" && $6 != "") print $5 "\t" $6
        if ($8 != "" && $9 != "") print $8 "\t" $9
    }' "$tsv")

    if (( bad_count == 0 )); then
        if (( file_count > 0 )); then
            substep "$vf_i" "$vf_total" "$w" "verified ($file_count file(s))"
        else
            substep "$vf_i" "$vf_total" "$w" "no files to verify"
        fi
    else
        substep "$vf_i" "$vf_total" "$w" "$bad_count of $file_count file(s) failed verification"
    fi

    ## Cleanup the TSV and any leftover working files
    rm -f "${out}/${w}/urls${w}.txt"
    rm -f "${out}/${w}/check${w}.tsv"
    rm -f "${out}/${w}/check${w}.txt"
    rm -f "${out}/${w}/proccessed_url${w}.txt"

done < list1

echo ""

duration=$(( SECONDS - start ))
echo "This run took $duration seconds"

rm -rf list 2>/dev/null
rm -rf list1 2>/dev/null
rm -rf PMCIDlist 2>/dev/null
rm -rf supp1 2>/dev/null
rm -rf lines 2>/dev/null
rm -rf tmp 2>/dev/null

#######  END  #######
