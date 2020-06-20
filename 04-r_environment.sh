#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
export R_LIBS=${SETUP_ROOT}/renv
mkdir -p ${R_LIBS}
if [ -z ${N_CPUS} ]; then N_CPUS=4; fi
# Remove non-default path to reduce interference (e.g., Conda)
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

# Install R packages
Rscript --vanilla -e \
'
R_LIBS <- Sys.getenv("R_LIBS")
N_CPUS <- Sys.getenv("N_CPUS")

install.packages(
    c(
        "devtools", "pacman", "fs", "here", "rprojroot", "styler", "feather", "processx", "languageserver",
        "tidyverse", "vroom", "broom", "janitor", "reticulate", "jsonlite",
        "data.table", "knitr", "kableExtra", "rmarkdown", "formatR", "printr",
        "dbplyr", "DBI", "RSQLite", "lintr", "Rmpi"
    ),
    lib = R_LIBS, repos = "https://cloud.r-project.org",
    clean = TRUE, Ncpus = N_CPUS
)

install.packages(
    c(
        "ggforce", "ggpmisc", "ggExtra", "ggfortify", "ggthemes", "ggsci", "paletteer",
        "GGally", "ggridges", "ggraph", "lemon", "cowplot", "ggpubr", "corrplot", "ggbeeswarm",
        "ggThemeAssist", "shades", "visreg", "magick", "tidygraph", "wesanderson"
    ),
    lib = R_LIBS, repos = "https://cloud.r-project.org",
    clean = TRUE, Ncpus = N_CPUS
)

install.packages(
    c(
        "psych", "afex", "emmeans", "coin", "robustbase", "Rmisc", "lme4", "lmerTest",
        "mediation", "NPC", "jmv", "sjPlot", "finalfit", "cocor", "skimr",
        "neurobase", "RNifti", "R.matlab",
        "vitae", "rorcid"
    ),
    lib = R_LIBS, repos = "https://cloud.r-project.org",
    clean = TRUE, Ncpus = N_CPUS
)

install.packages(
    c("tidyverse", "afex", "phia", "snow", "nlme", "lme4", "paran", "psych", "brms", "corrplot", "metafor"),
    lib = R_LIBS, repos = "https://cloud.r-project.org",
    clean = TRUE, Ncpus = N_CPUS
)
'

echo "Installation completed!"

echo "
Add 'R_LIBS=${R_LIBS}' into ~/.Renviron
"
