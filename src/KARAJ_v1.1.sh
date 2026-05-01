#!/bin/bash
####################################################################################################################################################
#							KARAJ:      a command-line software to automate and streamline acquiring biological data       					       #
#   						Version:    v1.1								                  					                                   #
#							About:      Developed in Computational Biology Lab, Children's Cancer Institute, University of New South Wales.   	   #
#							Developer:  Ali Afrasiabi                                                                                              #
####################################################################################################################################################

set -uo pipefail

#********************************* FUNCTION checkInstallation *********************************
# Verify that all external tools KARAJ depends on are installed and available.
# Checks for: ascp (via detect_aspera), lynx, efetch+esearch (NCBI Entrez Direct),
# curl, and the auxiliary tools axel, parallel, wget, bc.
# Caches the result via _KARAJ_CHECKED so repeated calls are no-ops.
# Side effect: prints a readiness banner on success, an error and exits 1 on failure.
# Returns: 0 if all dependencies are present (or already checked); exits 1 otherwise.
function checkInstallation
{
    if [[ -n "${_KARAJ_CHECKED:-}" ]]; then
        return 0
    fi
    _KARAJ_CHECKED=1

    # Probe each required tool; record a non-empty marker string when found
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

    # Check auxiliary tools; collect any that are missing
    local missing_extras=""
    for t in axel parallel wget bc; do
        if ! command -v "$t" >/dev/null 2>&1; then
            missing_extras+=" $t"
        fi
    done

    # All four core markers must be set AND no auxiliary tools missing
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
# Print the KARAJ version banner: name, version number, affiliation, developer
# contact, acknowledgements, and source code URL.
# Invoked by the -v command-line flag.
# Side effect: writes the banner to stdout.
# Returns: 0.
function Version
{
    echo ""
    echo "KARAJ:      a command-line software to automate and streamline acquiring biological data"
    echo "Version:    v1.1"
    echo "About:      developed in the Computational Biology Lab, Children's Cancer Institute, University of New South Wales."
    echo "Developer:  Ali Afrasiabi (a.afrasiabi@unsw.edu.au)"
    echo "Acknowledgement: Mahdieh Labani (m.labani@unsw.edu.au) contributed to the development of v1.0."
    echo "Code:       https://github.com/GTP-programmers/KARAJ"
    echo ""
}


#********************************* FUNCTION usage *********************************
# Print the help text describing every command-line flag KARAJ accepts:
# input modes (-l, -p, -f, -i), output and resource controls (-o, -j),
# filters (-t, -d, -s, -m, -n), and information flags (-h, -u, -v).
# Invoked by the -h command-line flag and when no arguments are supplied.
# Side effect: writes the help text to stdout.
# Returns: 0.
function usage
{
    echo ""
    echo "Instruction: the list of operations and options that are supported by KARAJ v1.1"
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
# Print detailed, copy-pasteable usage examples grouped by purpose:
# mode flags (-l, -p, -f, -i), output and resource flags (-o, -j),
# filtering and content selection (-t, -d, -s, -m), information flags
# (-h, -u, -v), and notes on flag combinations and exclusivity.
# Invoked by the -u command-line flag.
# Side effect: writes the example block to stdout via a single heredoc.
# Returns: 0.
function Example
{
    cat <<'EOF'

KARAJ usage examples
*********************************

Mode flags (one is required: -l, -p, -f, or -i)

  -p   Start from one or more PMCIDs
       KARAJ.sh -p PMC3737249
       KARAJ.sh -p PMC3737249 PMC4286305 -o /data/karaj_out

  -l   Start from one or more PMC article URLs
       KARAJ.sh -l https://pmc.ncbi.nlm.nih.gov/articles/PMC3737249/
       KARAJ.sh -l https://pmc.ncbi.nlm.nih.gov/articles/PMC3737249/ \
                   https://pmc.ncbi.nlm.nih.gov/articles/PMC4286305/

  -i   Start from one or more accession numbers (GSE/PRJNA/SRP/ERP/SRR/...)
       KARAJ.sh -i GSE38676
       KARAJ.sh -i SRR513107 SRR513108

  -f   Start from a file in the current directory
         -f 1   reads PMCID.txt        (one PMCID per line)
         -f 2   reads ACCESSIONS.txt   (one accession per line)
         -f 3   reads URLS.txt         (one URL per line)

       echo PMC3737249 > PMCID.txt
       KARAJ.sh -f 1 -o /data/karaj_out

       printf "GSE38676\nSRR513107\n" > ACCESSIONS.txt
       KARAJ.sh -f 2

Output and resources

  -o   Output working directory (default: current directory)
       KARAJ.sh -i GSE38676 -o /data/karaj_out

  -j   Number of cores for parallel Aspera transfers (default: nproc - 1)
       KARAJ.sh -i GSE38676 -j 8

Filtering and content selection

  -t   Restrict downloads to a single file type: bam | fastq | fasta | vcf
       KARAJ.sh -i GSE38676 -t fastq
       KARAJ.sh -p PMC3737249 -t bam -o /data/karaj_out

  -d   Interactively select which accession(s) to download from the summary
         -d 0   download all (default)
         -d 1   prompt the user to choose by index from the printed summary
       KARAJ.sh -p PMC3737249 -d 1

  -s   Download supplementary data (xlsx, txt, tsv, zip, ...) from the article
         -s 0   skip (default)
         -s 1   download supplementary files; KARAJ exits after this step
       KARAJ.sh -p PMC3737249 -s 1 -o /data/karaj_out

  -m   Generate a per-study metadata table (sample names, run IDs, sample IDs)
         -m 1   write *_metadata files; KARAJ exits after this step
       KARAJ.sh -i GSE38676 -m 1 -o /data/karaj_out

Information flags (no mode flag needed)

  -h   Print the help message
       KARAJ.sh -h

  -u   Print these usage examples
       KARAJ.sh -u

  -v   Print version and about
       KARAJ.sh -v

Combining flags

  Typical end-to-end run, fastq only, 8 cores, custom output:
       KARAJ.sh -p PMC3737249 -t fastq -j 8 -o /data/karaj_out

  Inspect first, download later:
       KARAJ.sh -p PMC3737249              # see the summary
       KARAJ.sh -i GSE38676 -t fastq       # download the one you wanted

Notes
  -l and -p accept multiple values: -p PMC1 PMC2 PMC3
  -s 1 and -m 1 are exclusive operations: KARAJ exits after completing them
  Only one mode flag (-l, -p, -f, -i) may be used per invocation

EOF
}


#********************************* FUNCTION download_geo_supplementary *********************************
# Download GEO supplementary RAW tarball for a GSE that has no SRA runs
# (microarray, ChIP-chip, etc). Files live under GEO's suppl/ directory:
#   ftp.ncbi.nlm.nih.gov/geo/series/GSE49nnn/GSE49628/suppl/GSE49628_RAW.tar
# Args:   $1 = GSE accession
# Output: writes ${GSE}_RAW.tar (and any other suppl/ files) to ${out}/${GSE}/
# Network: 1 lynx call to list suppl/, then 1 axel call per file
# Returns: 0 on success, 1 if no files found or download failed
download_geo_supplementary()
{
    local B="$1"
    local X y suppl_url file_list

    if [[ ! "$B" =~ ^GSE[0-9]+$ ]]; then
        return 1
    fi

    X=$(echo "$B" | rev | cut -c4- | rev)
    y="${X}nnn"
    suppl_url="https://ftp.ncbi.nlm.nih.gov/geo/series/${y}/${B}/suppl/"

    mkdir -p "${out}/${B}"

    # List the directory and pick out files (anything that's not a parent link)
    file_list=$(lynx -dump -listonly "$suppl_url" 2>/dev/null \
        | awk '{print $2}' \
        | grep -E "^https://ftp\.ncbi\.nlm\.nih\.gov/geo/series/${y}/${B}/suppl/." \
        | grep -v '/$' \
        | sort -u)

    if [[ -z "$file_list" ]]; then
        echo "  no supplementary files found for ${B} at ${suppl_url}" >&2
        return 1
    fi

    local n_files
    n_files=$(echo "$file_list" | wc -l)
    echo "  ${B}: downloading ${n_files} supplementary file(s) from GEO"

    while IFS= read -r u; do
        [[ -z "$u" ]] && continue
        local fname
        fname=$(basename "$u")
        if [[ -s "${out}/${B}/${fname}" ]]; then
            echo "    already present, skipping: ${fname}"
            continue
        fi
        # -n 4: NCBI rate-limits aggressive parallelism with 503s
        axel -q -n 4 "$u" -o "${out}/${B}/" \
            && echo "    downloaded: ${fname}" \
            || echo "    FAILED: ${fname}" >&2
    done <<<"$file_list"

    return 0
}


#********************************* FUNCTION detect_aspera *********************************
# Locate the ascp binary and its SSH key by checking known install locations
# (Aspera SDK and Aspera Connect) and respecting user-supplied overrides via
# the ASCP_BIN and ASCP_KEY environment variables.
# Side effect: sets the global variables ASCP_BIN and ASCP_KEY on success.
# Returns: 0 if both the binary and the key are found and valid; 1 otherwise.
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
            # Confirm it's actually ascp and not some other binary on PATH
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
# Fetch a single PMC article URL once and extract all four supported accession
# types (GSE, PRJNA, ERP, SRP) from its rendered text. Deduped accessions are
# appended to the output file; if nothing new was added the function prints a
# notice naming the PMCID (or URL if no PMCID can be parsed).
# Args:   $1 = article URL (typically https://pmc.ncbi.nlm.nih.gov/articles/PMCxxxxx/)
#         $2 = path to file to APPEND deduped accessions to
# Output: appends one accession per line to $2; the file is re-sorted and deduped in place
# Side effect: prints "There is no accession number..." to stdout if this paper contributed none
# Network: 1 lynx call per URL
# Returns: 0 on success, 1 if the URL could not be fetched
extract_accessions_from_url()
{
    local url="$1"
    local outfile="$2"
    local types=("GSE" "PRJNA" "ERP" "SRP")
    local dump before after Z i

    # Snapshot existing line count so we can tell whether THIS paper contributed anything
    before=0
    [[ -s "$outfile" ]] && before=$(wc -l <"$outfile")

    dump=$(lynx -dump "$url" 2>/dev/null) || {
        echo "WARNING: failed to fetch $url" >&2
        return 1
    }

    # Extract each accession type from the cached dump (no extra network calls)
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
# Download the GEO series matrix for a GSE accession and produce a tab-separated
# metadata file with columns Sample_name, RunID, SampleID, derived from the
# !Sample_title, !Sample_geo_accession, and !Sample_source_name_ch1 fields of
# the series matrix. Non-GSE accessions are skipped with a notice.
# Reads global: $out (output working directory).
# Args:   $1 = accession (only GSE* accepted; others skipped with a message)
# Output: writes a tab-separated table to ${out}/${B}/${B}_metadata.
# Side effect: creates ${out}/${B}/ and writes/removes a transient
#              series_matrix.txt during processing.
# Network: 1 wget per call.
# Returns: 0 on success or for non-GSE skip; 1 if the series matrix could not
#          be fetched or arrived empty.
generate_metadata_table()
{
    local B="$1"
    local X y url series_matrix titles accessions sources

    if [[ ! "$B" =~ ^GSE[0-9]+$ ]]; then
        echo "Skipping metadata for ${B}: only GEO series (GSE) accessions are supported." >&2
        return 0
    fi

    # GEO FTP layout: GSE12345 -> /geo/series/GSE12nnn/GSE12345/matrix/...
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

    # Write the table: header line, then paste the three columns side by side
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
# Print a human-readable summary block for one accession to stdout. For a GEO
# series (GSE), fetch the series_matrix file from NCBI's FTP server and the GDS
# entry via Entrez Direct, then extract the overall experiment design,
# description, type, and sample count. For non-GSE accessions (SRR, ERP, etc.)
# emit a short placeholder block since GEO series-matrix summaries don't apply.
# Reads global: $out (output working directory).
# Args:   $1 = accession (GSE or any other supported prefix)
#         $2 = display index (the "1." / "2." prefix shown in the summary list)
# Output: writes the summary block to stdout, terminated by a divider line.
# Side effect: creates ${out}/${accession}/ and writes a temporary
#              series_matrix.txt that is removed before returning (GSE only).
# Network: 1 wget + 1 esearch+efetch per GSE; 0 for non-GSE.
# Returns: 0 in all cases (network failures degrade gracefully to empty fields).
print_summary_report()
{
    local B="$1"
    local C="$2"
    local X y url D series_matrix gds_info

    # Non-GSE accessions: short placeholder block, no network calls
    if [[ ! "$B" =~ ^GSE[0-9]+$ ]]; then
        echo "${C}. ${B}"
        echo "Direct SRA/SRR accession; GEO series matrix summary skipped."
        echo "##############################################"
        return 0
    fi

    # GEO FTP layout: GSE12345 -> /geo/series/GSE12nnn/GSE12345/matrix/...
    X=$(echo "$B" | rev | cut -c4- | rev)
    y="${X}nnn"
    url="https://ftp.ncbi.nlm.nih.gov/geo/series/${y}/${B}/matrix/${B}_series_matrix.txt.gz"

    mkdir -p "${out}/${B}"
    wget -q -P "${out}/${B}" "$url"

    # Extract the overall experiment design (one line) from the series matrix
    D=""
    if [[ -s "${out}/${B}/${B}_series_matrix.txt.gz" ]]; then
        gunzip -f "${out}/${B}/${B}_series_matrix.txt.gz"
        series_matrix="${out}/${B}/${B}_series_matrix.txt"
        D=$(grep '^!Series_overall_design' "$series_matrix" \
            | sed 's/!Series_overall_design//; s/^[[:space:]]*//; s/"//g')
    fi

    # Pull description / type / platform from the GDS Entrez record
    # The "1." line in efetch output is the description, "2." is the type
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
# Query ENA's filereport API for a single run accession and write the
# tab-separated response to a file. The TSV columns are run_accession,
# fastq_ftp, fastq_md5, fastq_bytes, sra_ftp, sra_md5, sra_bytes,
# submitted_ftp, submitted_md5, submitted_bytes. This replaces the previous
# ffq dependency in the download stage.
# Args:   $1 = run accession (SRR/ERR/DRR)
#         $2 = output file path
# Output: writes the TSV response to $2.
# Network: 1 curl call (with up to 3 retries, 60s timeout).
# Returns: 0 if the API returned a real data row (more than just the header);
#          1 on network error, unknown accession, or header-only response.
fetch_ena_filereport()
{
    local acc="$1"
    local out_tsv="$2"
    local url

    # Build the URL piecewise so the field list stays readable
    url="https://www.ebi.ac.uk/ena/portal/api/filereport"
    url+="?accession=${acc}"
    url+="&result=read_run"
    url+="&fields=run_accession,fastq_ftp,fastq_md5,fastq_bytes,sra_ftp,sra_md5,sra_bytes,submitted_ftp,submitted_md5,submitted_bytes"
    url+="&format=tsv"

    if ! curl -sSL --retry 3 --max-time 60 "$url" -o "$out_tsv" 2>/dev/null; then
        return 1
    fi

    # Reject empty/header-only responses (ENA returns a header row even for
    # unknown accessions, so we require at least 2 lines)
    if [[ ! -s "$out_tsv" ]] || (( $(wc -l <"$out_tsv") < 2 )); then
        return 1
    fi

    return 0
}

#********************************* FUNCTION phase *********************************
# Print a top-level stage transition line of the form "[step/total] message".
# Used to mark the major phases of a KARAJ run (resolving accessions, fetching
# ENA records, checking disk space, building URL list, downloading, verifying).
# Args:   $1 = current step number
#         $2 = total number of steps
#         $@ (after shift 2) = the message to print
# Output: writes the formatted line to stdout.
# Returns: 0.
phase()
{
    local step="$1"
    local total="$2"
    shift 2
    echo "[${step}/${total}] $*"
}

#********************************* FUNCTION substep *********************************
# Print a per-iteration progress line of the form "  [i/n] label... [status]".
# Indented under the parent phase. If status is omitted the line ends in "...".
# Used inside loops that iterate over accessions or files within a phase.
# Args:   $1 = current iteration index
#         $2 = total iterations
#         $3 = label (typically the accession)
#         $4 = optional status string ("done", "FAILED", "verified", etc.)
# Output: writes the formatted line to stdout.
# Returns: 0.
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
# Compare a file's MD5 checksum against an expected lowercase-hex value.
# Used during phase 6 to validate every downloaded file against the MD5 columns
# returned by ENA's filereport API.
# Args:   $1 = file path
#         $2 = expected MD5 (lowercase hex)
# Returns: 0 if the file exists and its MD5 matches; 1 if missing or mismatched.
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

#********************************* FUNCTION download_progress_monitor *********************************
# Periodically poll the size of in-flight download files in a directory and
# print a single overwriting progress bar to stderr showing percent, bytes
# transferred, average speed, and ETA. Tracks both finished files (e.g.
# *.fastq.gz, *.bam, *.sra) and Aspera's in-progress *.partial counterparts so
# the bar advances during the transfer rather than jumping at completion.
# Exits when the watched process (typically the backgrounded ascp/parallel
# wrapper) terminates, then prints a final 100% summary line.
# Usage:  download_progress_monitor <out_dir> <expected_bytes> <ascp_pid>
# Args:   $1 = directory where ascp is writing files (.partial files also matched)
#         $2 = total bytes expected to be transferred (0 disables percent/ETA
#              but still shows bytes and speed)
#         $3 = PID of the backgrounded parent process; the monitor exits as
#              soon as this PID is no longer alive
# Output: writes to stderr only (single line, repeatedly overwritten with \r;
#         a final newline-terminated summary line on exit)
# Returns: 0.
download_progress_monitor()
{
    local out_dir="$1"
    local total_bytes="$2"
    local watch_pid="$3"

    local start_ts
    local now_ts
    local elapsed
    local current_bytes
    local pct
    local rate
    local eta_sec
    local eta_str
    local bar
    local bar_filled
    local bar_empty
    local human_current
    local human_total
    local human_rate

    local bar_width=26

    start_ts=$(date +%s)

    # Loop until the watched process exits
    while kill -0 "$watch_pid" 2>/dev/null; do
        # Sum the bytes of all completed and .partial files in the dir
        current_bytes=$(find "$out_dir" -maxdepth 1 -type f \
            \( -name '*.fastq.gz' -o -name '*.fastq.gz.partial' \
            -o -name '*.bam' -o -name '*.bam.partial' \
            -o -name '*.fasta.gz' -o -name '*.fasta.gz.partial' \
            -o -name '*.vcf.gz' -o -name '*.vcf.gz.partial' \
            -o -name '*.sra' -o -name '*.sra.partial' \) \
            -printf '%s\n' 2>/dev/null | awk '{ sum += $1 } END { print sum+0 }')

        now_ts=$(date +%s)
        elapsed=$(( now_ts - start_ts ))
        # Avoid divide-by-zero on the very first iteration
        [[ "$elapsed" -lt 1 ]] && elapsed=1

        # Compute percent (clamped to 0..100); 0 if total is unknown
        if (( total_bytes > 0 )); then
            pct=$(awk -v c="$current_bytes" -v t="$total_bytes" \
                'BEGIN { p = c * 100 / t; if (p > 100) p = 100; printf "%d", p }')
        else
            pct=0
        fi

        # Compute average speed in bytes/sec over the whole transfer so far
        rate=$(( current_bytes / elapsed ))

        # Compute ETA from current rate; "--:--:--" while rate is unknown or
        # the total has already been reached/exceeded
        if (( rate > 0 && total_bytes > current_bytes )); then
            eta_sec=$(( (total_bytes - current_bytes) / rate ))
            eta_str=$(printf "%02d:%02d:%02d" $((eta_sec/3600)) $(((eta_sec%3600)/60)) $((eta_sec%60)))
        else
            eta_str="--:--:--"
        fi

        # Build the bar: "====>     " sized to bar_width
        bar_filled=$(( pct * bar_width / 100 ))
        bar_empty=$(( bar_width - bar_filled ))
        bar=$(printf '%*s' "$bar_filled" '' | tr ' ' '=')
        bar="${bar}>"
        bar="${bar}$(printf '%*s' "$bar_empty" '')"

        # Human-readable sizes (MB below 1 GB, GB above)
        human_current=$(awk -v b="$current_bytes" 'BEGIN {
            if (b > 1073741824) printf "%.2f GB", b/1073741824
            else printf "%.0f MB", b/1048576
        }')
        human_total=$(awk -v b="$total_bytes" 'BEGIN {
            if (b > 1073741824) printf "%.2f GB", b/1073741824
            else printf "%.0f MB", b/1048576
        }')
        # Network speed conventionally reported in Mbps (megabits/sec)
        human_rate=$(awk -v b="$rate" 'BEGIN {
            mbps = b * 8 / 1000000
            printf "%.0f Mbps", mbps
        }')

        # Print/overwrite (use \r so the line updates in place)
        printf '\r[%s] %3d%%  %s / %s   %s   ETA %s' \
            "$bar" "$pct" "$human_current" "$human_total" "$human_rate" "$eta_str" >&2

        sleep 1
    done

    # Final line — recompute totals (counting only completed files, since
    # *.partial files should be gone after a successful transfer) and print
    # a clean 100% summary terminated by a newline so it stays in scrollback
    elapsed=$(( $(date +%s) - start_ts ))
    [[ "$elapsed" -lt 1 ]] && elapsed=1

    current_bytes=$(find "$out_dir" -maxdepth 1 -type f \
        \( -name '*.fastq.gz' -o -name '*.bam' -o -name '*.fasta.gz' \
        -o -name '*.vcf.gz' -o -name '*.sra' \) \
        -printf '%s\n' 2>/dev/null | awk '{ sum += $1 } END { print sum+0 }')

    rate=$(( current_bytes / elapsed ))
    human_current=$(awk -v b="$current_bytes" 'BEGIN {
        if (b > 1073741824) printf "%.2f GB", b/1073741824
        else printf "%.0f MB", b/1048576
    }')
    human_rate=$(awk -v b="$rate" 'BEGIN {
        mbps = b * 8 / 1000000
        printf "%.0f Mbps", mbps
    }')

    printf '\r[%s] 100%%  %s   avg %s   in %02d:%02d:%02d        \n' \
        "$(printf '%*s' "$bar_width" '' | tr ' ' '=')" \
        "$human_current" "$human_rate" \
        $((elapsed/3600)) $(((elapsed%3600)/60)) $((elapsed%60)) >&2
}


#********************************* FUNCTION resolve_accession_to_gse *********************************
# For a single non-GSE study-level accession (ERP, SRP, PRJN, PRJNA), attempt
# to find one or more corresponding GEO series (GSE) accessions via NCBI's
# Entrez Direct. ERP/SRP are looked up directly in the GDS database; PRJN/
# PRJNA are first resolved to an SRP via SRA, then that SRP is looked up in
# GDS. GSE and run accessions (SRR/ERR/DRR) are passed through unchanged.
# Unknown prefixes are also passed through so the caller can handle them.
# Args:   $1 = accession
# Output (stdout): one accession per line — either the resolved GSE(s), the
#                  original accession (if already GSE/run/unknown), or nothing
#                  if resolution failed
# Network: 1-2 esearch+efetch calls (1 for ERP/SRP, 2 for PRJN/PRJNA)
# Returns: 0 if at least one accession was printed; 1 if resolution failed
#          (the caller should fall back to keeping the original accession)
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
            # PRJN/PRJNA → SRP first (column 21 of the SRA runinfo CSV is the
            # study accession), then SRP → GSE
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
# Helper that lets a single getopts flag accept multiple positional values
# (e.g. "-p PMC1 PMC2 PMC3"), which standard getopts does not support. After
# getopts has captured the first argument into OPTARG, this function walks
# subsequent positional arguments and appends each one to OPTARG until it hits
# the next flag (anything starting with "-") or the end of the argument list.
# Side effect: rewrites OPTARG into an array; advances OPTIND past every
#              additional value consumed.
# Returns: 0.
function getopts-extra()
{
    OPTARG=( "$OPTARG" )   # reset; preserve the value getopts already captured
    declare i=1
    while [[ ${OPTIND} -le $# && ${!OPTIND:0:1} != '-' ]]; do
        OPTARG[i]=${!OPTIND}
        let i++ OPTIND++
    done
}

#********************************* SECTION: command-line argument parsing *********************************
# Default values for every option, then standard getopts loop over the flags
# defined in usage()/Example(). Multi-value flags (-l, -p, -i) call
# getopts-extra to slurp additional positional values into the corresponding
# array. Information flags (-u, -h, -v) print and exit immediately. Unknown
# flags and missing arguments are reported but do not return non-zero — they
# call exit 0, matching the existing behavior of this script.
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

#********************************* SECTION: argument validation and setup *********************************
# Runs after the getopts loop. Validates that the caller supplied at least one
# mode flag, rejects stray positional arguments, ensures only one mode flag was
# used, then verifies the environment via checkInstallation and resolves the
# output working directory (creating it if needed) into the global $out.

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
# All subsequent file operations happen relative to $out. cd'ing into the
# output dir means transient files (PMCIDlist, list, list1) are created there
# rather than in the user's invocation directory.
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

#********************************* SECTION: PMCID input mode (-p) *********************************
# Build PMC article URLs from each supplied PMCID, then dispatch to one of
# three sub-flows based on flags:
#   -s 1  → download supplementary files for each article and exit
#   -m 1  → write per-study metadata tables and exit
#   else  → extract accession numbers, fetch article metadata, print a summary
#           report, and write the working list of accessions into ./list1 for
#           the download phase further down the script.

## making URL(s) from PMCID(s)
if [[ -v PMCID ]]; then
    : >PMCIDlist
    for j in "${!PMCID[@]}"; do
        if [[ ! "${PMCID[j]}" =~ ^PMC[0-9]+$ ]]; then
            echo "WARNING: '${PMCID[j]}' does not look like a PMCID (expected PMC followed by digits); proceeding anyway." >&2
        fi
        echo "https://pmc.ncbi.nlm.nih.gov/articles/${PMCID[j]}/" >>PMCIDlist
    done
    sort -u PMCIDlist -o PMCIDlist

    ## obtaining supplementary tables using PMCID
    # Scrapes article HTML for any .xlsx/.tsv/.txt/.zip links, filters out
    # navigation links to other PMC articles, then downloads each unique URL
    # via axel. Skips files already present. Exits 0 after this block — -s 1
    # is a terminal operation and never falls through to accession extraction.
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
                # Strip query/fragment suffixes when computing the local filename
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
    # For each URL, extract accessions into a per-paper temp file (so we can
    # also pass it to fetch_pubmed_metadata for inclusion in article_info.txt),
    # then accumulate everything into the global ./list. The temp file is
    # removed after metadata generation.
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

    # No accessions found across any of the papers — nothing to download
    if [[ ! -s list ]]; then
        exit 0
    fi

    mapfile -t lines <list

    ## generating metadata
    # -m 1 is also terminal: write per-study tables and exit without proceeding
    # to the summary report or download phase
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
    echo "Selected for download:"
    echo "$(cat list)"
    echo "##############################################"
    echo ""
    # list1 drives the download phase further down; copying list -> list1 here
    # means "download everything we found" by default. The -d 1 selection block
    # later may further filter list1 before phase 1 starts.
    cp list list1
fi
	
#********************************* SECTION: URL input mode (-l) *********************************
# Same dispatch shape as the -p block above, except the URLs come straight
# from the user instead of being constructed from PMCIDs. Sub-flows:
#   -s 1  → download supplementary files for each URL and exit
#   -m 1  → write per-study metadata tables and exit
#   else  → extract accessions, capture article metadata, print summary,
#           and seed list1 for the download phase.

## fetching content for user-specified URL(s)
if [[ -v link ]]; then
    : >PMCIDlist
    for j in "${!link[@]}"; do
        echo "${link[j]}" >>PMCIDlist
    done
    sort -u PMCIDlist -o PMCIDlist
    cp PMCIDlist list1

    ## obtaining supplementary tables for each URL
    # Identical to the -p supplementary block — terminal: exits 0 after.
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
    # Identical to the -p accession-extraction block: per-URL temp file feeds
    # both the global ./list and the per-paper article_info.txt.
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
    echo "Selected for download:"
    echo "$(cat list)"
    echo "##############################################"
    echo ""
    cp list list1
fi

#********************************* SECTION: file input mode (-f) *********************************
# Read a list of inputs from a file in the current directory or $out:
#   -f 1  → PMCID.txt       (one PMCID per line)        → same as -p
#   -f 2  → ACCESSIONS.txt  (one accession per line)    → seeds list1 directly
#   -f 3  → URLS.txt        (one URL per line)          → same as -l
# Sub-flow flags (-s 1, -m 1) behave the same as in the -p / -l branches.

## searching for different types of accession numbers in the text of articles using list of PMCIDs, accession numbers or URLs that are specified by user
if [[ -v file ]];
	then
if [[ "$file" == '1' ]]; then
            ## locate PMCID.txt in PWD or $out
            # Resolution order: PWD first, then the output dir. The trailing
            # `|| [[ -n "$pmcid" ]]` on the read loop catches files that
            # don't end with a newline (common in editor-saved text files).
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
                echo "https://pmc.ncbi.nlm.nih.gov/articles/${pmcid}/" >>PMCIDlist
            done <"$pmcid_file"

            sort -u PMCIDlist -o PMCIDlist

            ## obtaining supplementary tables for each PMCID
            # Identical to the -p / -l supplementary blocks.
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
            # Identical to the -p / -l accession-extraction blocks.
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
            echo "Selected for download:"
            echo "$(cat list)"
            echo "##############################################"
            echo ""
            cp list list1
elif [[ "$file" == '2' ]]; then
    #----- -f 2: read accessions directly from ACCESSIONS.txt ------------
    # No URL fetching, no article metadata, no summary — accessions go
    # straight into list1 for the resolve-to-GSE step further down. This is
    # the fastest mode to invoke when you already know which studies/runs
    # you want.
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

#----- continuation of -f 2: resolve study accessions and summarise -----
    # ACCESSIONS.txt may contain mixed inputs — direct GSE accessions, run
    # accessions (SRR/ERR/DRR) which pass through, and study accessions
    # (ERP/SRP/PRJN/PRJNA) which need a 1-2 hop resolution to a GSE. The
    # subshell rewrites list1 in one pass, falling back to the original
    # accession when resolution fails so nothing is silently dropped.
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
    echo "Selected for download:"
    echo "$(cat list)"
    echo "##############################################"
    echo ""
	echo "##############################################" 
	echo ""
	
		
elif [[ "$file" == '3' ]]; then
            #----- -f 3: read URLs directly from URLS.txt --------------------
            # Same downstream behavior as -l (URLs come from a file instead
            # of the command line). Sub-flow flags -s 1 and -m 1 behave the
            # same as in the other input modes.
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
            # Identical to the supplementary blocks in the -p / -l / -f 1 branches.
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
            # Identical to the accession-extraction blocks in the -p / -l / -f 1 branches.
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
            echo "Selected for download:"
            echo "$(cat list)"
            echo "##############################################"
            echo ""
            cp list list1
   fi
# Note: the trailing `else echo ""; fi` exists because the outer
# `if [[ -v file ]]` was originally written without an explicit "no -f"
# branch. It's a no-op; could be removed in a cleanup pass.
else
  echo ""
fi


#********************************* SECTION: accession input mode (-i) *********************************
# Direct accession input from the command line. Skips the URL/article scraping
# entirely and goes straight to: dedupe → resolve study accessions to GSEs
# (ERP/SRP/PRJN/PRJNA → GSE) → either generate metadata (-m 1) or print the
# summary report and seed list1 for the download phase.

## downloading sequence data using a list of accession numbers
if [[ -v ID ]]; then
    : >list1
    for j in "${!ID[@]}"; do
        echo "${ID[j]}" >>list1
    done
    sort -u list1 -o list1

    ## resolve any non-GSE study accessions (ERP/PRJN/SRP/PRJNA) to GSEs
    # Per-line subshell pass: resolve where possible, fall back to the original
    # accession on failure so nothing is silently dropped.
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
    echo "Selected for download:"
    echo "$(cat list)"
    echo "##############################################"
    echo ""
fi

#********************************* SECTION: interactive accession selection (-d 1) *********************************
# When -d 1 is set, prompt the user to choose accessions by their printed index
# (the "1.", "2.", ... shown in the summary report). The user enters how many
# they want, then one index per prompt. Selected accessions REPLACE list1 (so
# only the chosen ones flow into the download phase). Indices outside the range
# of list1 are reported and skipped.
#
# When -d is unset or set to anything other than '1', list1 is left as-is and
# all accessions proceed to download.

## selecting specific accession number(s) to download
if [[ -v down ]]; then
    if [[ "$down" == '1' ]]; then
        echo "Enter the number of accession codes that you want to download: "
        read -r n

        # Validate the count is a positive integer
        if ! [[ "$n" =~ ^[0-9]+$ ]] || (( n < 1 )); then
            echo "ERROR: expected a positive integer, got: $n" >&2
            exit 1
        fi

        # Read each requested index into list2
        : >list2
        i=1
        while [[ $i -le $n ]]; do
            echo "Enter the number of accession: "
            read -r number
            if ! [[ "$number" =~ ^[0-9]+$ ]]; then
                echo "WARNING: '$number' is not a valid index; skipping." >&2
            else
                echo "$number" >>list2
            fi
            i=$((i + 1))
        done

        # Build the filtered list in a fresh file, then atomically replace
        # list1. (The previous version appended back to list1, which made the
        # list grow rather than shrink — the selection had no effect.)
        mapfile -t lines <list1
        : >list1.selected

        while IFS= read -r p; do
            [[ -z "$p" ]] && continue
            chosen_idx=$((p - 1))
            if (( chosen_idx < 0 )) || (( chosen_idx >= ${#lines[@]} )); then
                echo "WARNING: index $p is out of range (list has ${#lines[@]} entries); skipping." >&2
                continue
            fi
            echo "${lines[chosen_idx]}" >>list1.selected
        done <list2

        sort -u list1.selected -o list1.selected
        mv list1.selected list1
        rm -f list2

        echo "##############################################"
        echo "Selected to download:"
        cat list1
        echo "##############################################"
        echo ""
    fi
fi

#********************************* SECTION: final accession resolution before download *********************************
# A second resolve-to-GSE pass over list1. This is redundant for the -i and
# -f 2 input modes (which already resolved before the summary), but it's the
# first resolution step for the -p / -l / -f 1 / -f 3 modes (where list1 was
# populated directly from accessions extracted from article text). Cheap,
# idempotent — safe to run unconditionally.

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


#********************************* SECTION: phase 1 — resolve to run accessions *********************************
# At this point list1/list contains a mix of accession types: run accessions
# (SRR/ERR/DRR), GEO series (GSE), study accessions (already resolved to GSE
# in earlier sections), and possibly individual GSM samples. The download
# stage needs run accessions specifically (Aspera URLs are per-run), so this
# section walks each entry and resolves it via the most appropriate route:
#
#   - SRR/ERR/DRR runs           → pass through unchanged
#   - SRA-queryable accessions   → esearch+efetch the SRA runinfo CSV
#   - GSE                        → fetch the series matrix, extract GSMs from
#                                  !Sample_geo_accession, then resolve each
#                                  GSM via SRA. (Direct GSE→SRA queries are
#                                  unreliable; going through GSMs is robust.)
#   - everything else            → pass through; phase 2 will reject if ENA
#                                  has no record
#
# Anything that doesn't resolve cleanly is kept as-is so phase 2 can decide
# its fate via the ENA filereport API. The result replaces both list and list1.

phase 1 6 "Resolving accessions to runs..."

## Resolve study/sample/GEO accessions to run accessions before download
if [[ -s list ]]; then
    tmp_run_list=$(mktemp)

    while IFS= read -r acc <&3; do
        [[ -z "$acc" ]] && continue

        # Already a run accession — keep it
        if [[ "$acc" =~ ^(SRR|ERR|DRR)[0-9]+$ ]]; then
            echo "$acc" >>"$tmp_run_list"
            continue
        fi

        # Try the direct SRA route first (works for SRP/PRJN/SRX/SRS/etc.)
        run_hits=$(esearch -db sra -query "$acc" 2>/dev/null \
            | efetch -format runinfo 2>/dev/null \
            | awk -F',' 'NR>1 && $1 ~ /^(SRR|ERR|DRR)[0-9]+$/ {print $1}' | sort -u)

        if [[ -n "$run_hits" ]]; then
            echo "$run_hits" >>"$tmp_run_list"
            continue
        fi

        # GSE fallback: pull GSM list from the series matrix on GEO FTP, then
        # resolve each GSM individually via SRA. More reliable than expecting
        # a direct GSE→SRA mapping in Entrez Direct.
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
            if [[ -n "$(echo "$gse_run_hits" | tr -d "[:space:]")" ]]; then
                echo "$gse_run_hits" >>"$tmp_run_list"
            else
                # No SRA runs — likely microarray. Route to GEO suppl/ download.
                echo "  ${acc}: no SRA runs found, marking for GEO supplementary download" >&2
                echo "$acc" >>"${out}/array_list"
            fi
        else
            # Unknown prefix — keep as-is
            echo "$acc" >>"$tmp_run_list"
        fi
    done 3<list

sort -u "$tmp_run_list" | sed '/^$/d' >list
    cp list list1
    rm -f "$tmp_run_list"

    echo "Resolved download accession(s):"
    cat list
    echo ""

    # Drain microarray queue: download GEO suppl/ tarballs for any GSEs
    # that didn't resolve to runs. These bypass phases 2-6 entirely.
    if [[ -s "${out}/array_list" ]]; then
        echo "GEO supplementary downloads (non-sequencing studies):"
        sort -u "${out}/array_list" -o "${out}/array_list"
        while IFS= read -r gse; do
            [[ -z "$gse" ]] && continue
            download_geo_supplementary "$gse"
        done <"${out}/array_list"
        echo ""
    fi
fi


#********************************* SECTION: phase 2 — fetch ENA file records *********************************
# Query ENA's filereport API for every run accession and cache the TSV under
# ${out}/${acc}/check${acc}.tsv. Accessions ENA doesn't recognise are dropped
# from list / list1 and their working dirs removed, so downstream phases only
# see entries that have a real record.

phase 2 6 "Fetching ENA file records..."

## Per-accession: fetch ENA filereport TSV (replaces ffq --ftp)
fetch_total=$(wc -l <list)
fetch_i=0
for j in $(cat list); do
    fetch_i=$((fetch_i + 1))
    mkdir -p "${out}/$j"

    if ! fetch_ena_filereport "$j" "${out}/$j/check$j.tsv"; then
        substep "$fetch_i" "$fetch_total" "$j" "no record found"
        # Use grep -vxF for an exact, fixed-string, line-anchored match —
        # otherwise dropping "SRR123" would also drop "SRR1234".
        grep -vxF "$j" list | sort -u >tmp && mv tmp list
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


#********************************* SECTION: phase 3 — disk space check *********************************
# Compute total bytes needed across all accessions (using the column that
# matches the user's -t selection, since fastq/sra/submitted are alternative
# encodings of the same data and we'll only download one) and compare against
# bytes available on the filesystem holding $out. Exits 1 if there isn't
# enough room — the previous version erroneously exited 0 (success) and also
# deleted the user's working files.

phase 3 6 "Disk space check..."
echo ""

# Pick the bytes column corresponding to the file type we'll actually fetch.
#   fastq           → column 4 (fastq_bytes)
#   bam/fasta/vcf   → column 10 (submitted_bytes)
#   anything else   → column 4
case "${type:-fastq}" in
    fastq)            bytes_col=4 ;;
    bam|fasta|vcf)    bytes_col=10 ;;
    *)                bytes_col=4 ;;
esac

# Available bytes on the filesystem holding $out. -B1 forces bytes; no unit
# suffix to parse. (Previous version used -h and tried to strip 'G', which
# silently broke when df reported T or M.)
avail_bytes=$(df -B1 --output=avail "$out" | tail -1 | tr -d ' ')

# Required bytes summed across every accession's TSV
required_bytes=0
for j in $(cat list); do
    [[ -s "${out}/$j/check$j.tsv" ]] || continue
    acc_bytes=$(awk -F'\t' -v c="$bytes_col" '
        NR>1 && $c != "" {
            n = split($c, sizes, ";")
            for (k=1; k<=n; k++) total += sizes[k]+0
        }
        END { printf "%d", total+0 }
    ' "${out}/$j/check$j.tsv")
    required_bytes=$((required_bytes + acc_bytes))
done

# Human-readable conversion for the message lines
to_gb() { awk -v b="$1" 'BEGIN { printf "%.2f", b/1073741824 }'; }
avail_gb=$(to_gb "$avail_bytes")
required_gb=$(to_gb "$required_bytes")

if (( avail_bytes > required_bytes )); then
    echo
    echo "------------------------------------------------------------------"
    echo "Available space in ${out}: ${avail_gb} GB"
    echo "Required for download:    ${required_gb} GB"
    echo "There is adequate space to download all specified files."
    echo "------------------------------------------------------------------"
    echo
else
    echo
    echo "---------------------------------------------------------------------------------------------------"
    echo "Available space in ${out}: ${avail_gb} GB"
    echo "Required for the following accession(s):"
    cat list
    echo "Total: ${required_gb} GB"
    echo
    echo "${out} does not have enough space for all files. Please choose a different output directory (-o)."
    echo "---------------------------------------------------------------------------------------------------"
    echo
    # Don't delete list/list1/PMCIDlist — leave user's resolved work intact.
    exit 1
fi


#********************************* SECTION: phase 4 — build per-accession URL lists *********************************
# For each accession in list1, read the cached ENA filereport TSV and extract
# the FTP/Aspera URLs corresponding to the user's chosen file type. URLs are
# rewritten from ENA's FTP host to the Aspera fasp endpoint (era-fasp@...) so
# ascp can transfer them in phase 5. Per-accession URL lists are written to
# ${out}/${acc}/urls${acc}.txt.

phase 4 6 "Building Aspera URL list..."

#----- helper: byte total per accession (for progress bar / disk check) -----
# Sum the bytes column matching the requested file type. Used by the download
# loop to size the progress bar.
#   fastq           → column 4 (fastq_bytes)
#   bam/fasta/vcf   → column 10 (submitted_bytes)
#   sra/unset/other → column 4 (fastq_bytes, the most common case)
extract_bytes_for_type() {
    local tsv="$1"
    local want_type="$2"
    local col=""

    case "$want_type" in
        fastq)              col=4 ;;
        bam|fasta|vcf)      col=10 ;;
        sra|"")             col=4 ;;
        *)                  col=4 ;;
    esac

    awk -F'\t' -v c="$col" 'NR>1 && $c != "" {
        n = split($c, sizes, ";")
        for (k=1; k<=n; k++) total += sizes[k]+0
    } END { print total+0 }' "$tsv"
}

#----- helper: download URLs per accession -----
# Pull the URL column matching the requested file type, split semicolon-
# separated lists into separate lines, and rewrite ENA's FTP host into the
# Aspera fasp endpoint. The rewrite (ftp.sra.ebi.ac.uk/ → era-fasp@...:/) is
# the key that makes the URLs ascp-compatible.
extract_urls_for_type() {
    local tsv="$1"
    local want_type="$2"
    local col=""

    case "$want_type" in
        fastq)              col=2 ;;
        bam|fasta|vcf)      col=8 ;;
        sra|"")             col=2 ;;
        *)                  col=2 ;;
    esac

    awk -F'\t' -v c="$col" 'NR>1 && $c != "" {
        n = split($c, urls, ";")
        for (k=1; k<=n; k++) print urls[k]
    }' "$tsv" | grep -v '^$' | sed 's#^ftp\.sra\.ebi\.ac\.uk/#era-fasp@fasp.sra.ebi.ac.uk:/#'
}

# Dispatch on -t: explicit type → use that column; no -t → fall back through
# fastq → bam → sra so we get something downloadable for any record shape.
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
    # No -t specified: prefer fastq, then bam, then submitted (column 5).
    # The column-5 fallback is handled inline since extract_urls_for_type
    # doesn't have an "sra-via-column-5" mode.
    for j in $(cat list1); do
        urls=$(extract_urls_for_type "${out}/$j/check$j.tsv" fastq)
        [[ -z "$urls" ]] && urls=$(extract_urls_for_type "${out}/$j/check$j.tsv" bam)
        [[ -z "$urls" ]] && urls=$(awk -F'\t' 'NR>1 && $5 != "" {n=split($5, u, ";"); for (k=1; k<=n; k++) print u[k]}' "${out}/$j/check$j.tsv" \
            | grep -v '^$' | sed 's#^ftp\.sra\.ebi\.ac\.uk/#era-fasp@fasp.sra.ebi.ac.uk:/#')
        echo "$urls" >"${out}/$j/urls$j.txt"
    done
fi


#********************************* SECTION: phase 5 — download via Aspera *********************************
# Pre-flight: confirm ascp + key are still available, parallel is installed,
# and list1 exists. Determine the parallelism level (-j override or nproc-1).
# Then iterate accessions sequentially, fanning out runs WITHIN each accession
# via parallel + ascp, with download_progress_monitor watching the output dir
# in the foreground while parallel runs in the background. wait recovers the
# real exit status.

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

# Parallelism: explicit -j wins; otherwise leave one core free for the OS.
if [[ -v core && -n "$core" ]]; then
    k="$core"
else
    k=$(nproc)
    k=$((k - 1))
    if [[ "$k" -lt 1 ]]; then
        k=1
    fi
fi

echo "(using ${k} cores)"
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

    # Total bytes for this accession — feeds the progress bar's percent/ETA
    expected_bytes=$(extract_bytes_for_type "${out}/${w}/check${w}.tsv" "${type:-fastq}")

    substep "$dl_i" "$dl_total" "$w" "downloading"

    # Background parallel so download_progress_monitor can watch the dir while
    # ascp writes. ascp's own progress is suppressed via -q so it doesn't
    # collide with the monitor's bar.
    parallel -j "$k" -- "$ASCP_BIN" -q -T -l 300m --retry-timeout=1800 \
        -P33001 -i "$ASCP_KEY" {} "${out}/${w}" \
        < "$URL_FILE" >/dev/null 2>&1 &
    ascp_pid=$!

    download_progress_monitor "${out}/${w}" "${expected_bytes:-0}" "$ascp_pid"

    # Recover the real exit status — $? after a backgrounded job needs wait
    wait "$ascp_pid"
    ascp_status=$?

    if [[ $ascp_status -ne 0 ]]; then
        substep "$dl_i" "$dl_total" "$w" "FAILED"
        exit 1
    fi

    substep "$dl_i" "$dl_total" "$w" "completed"
done < list1

echo ""


#********************************* SECTION: phase 6 — verify MD5 checksums *********************************
# Iterate accessions in list1, reread the ENA TSV, and check every downloaded
# file's MD5 against the expected value. ENA reports MD5+filename pairs in
# three column pairs:
#   columns 2,3   → fastq_ftp,    fastq_md5
#   columns 5,6   → sra_ftp,      sra_md5
#   columns 8,9   → submitted_ftp, submitted_md5
# Each cell may contain multiple entries separated by ';'. Files that fail
# verification are deleted (so a re-run picks them up clean).

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

    bad_count=0
    file_count=0

    # Inner loop reads (url, md5) pairs emitted from the awk pre-processor below
    while IFS=$'\t' read -r ftp_url expected_md5; do
        [[ -z "$ftp_url" || -z "$expected_md5" ]] && continue

        # Each cell may contain multiple semicolon-separated entries
        IFS=';' read -ra urls  <<< "$ftp_url"
        IFS=';' read -ra md5s  <<< "$expected_md5"

        for idx in "${!urls[@]}"; do
            file_url="${urls[$idx]}"
            file_md5="${md5s[$idx]:-}"
            [[ -z "$file_url" || -z "$file_md5" ]] && continue

            file_name=$(basename "$file_url")
            file_path="${out}/${w}/${file_name}"

            file_count=$((file_count + 1))

            # Skip files that didn't download (e.g. type filter excluded them)
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

    # Cleanup transient working files; keep the downloaded data and any
    # article_info.txt / metadata that earlier phases produced.
    rm -f "${out}/${w}/urls${w}.txt"
    rm -f "${out}/${w}/check${w}.tsv"
    rm -f "${out}/${w}/check${w}.txt"
    rm -f "${out}/${w}/proccessed_url${w}.txt"

done < list1

echo ""

duration=$(( SECONDS - start ))
echo "This run took $duration seconds"

#********************************* SECTION: cleanup *********************************
# Remove top-level working files. These all live in $out (we cd'd there at
# startup), so this only deletes KARAJ's own temp state, not anything the
# user put there.
rm -rf list 2>/dev/null
rm -rf list1 2>/dev/null
rm -rf PMCIDlist 2>/dev/null
rm -rf supp1 2>/dev/null
rm -rf lines 2>/dev/null
rm -rf tmp 2>/dev/null
rm -rf array_list 2>/dev/null   # ADD THIS LINE

#######  END  #######
