#!/bin/bash

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
export R_LIBS=${SETUP_ROOT}/renv
CRAN=${CRAN:-https://packagemanager.rstudio.com/all/__linux__/focal/latest}
N_CPUS=${N_CPUS:-4}
echo "R library location: ${R_LIBS}"
mkdir -p ${R_LIBS}
Rscript -e "install.packages(c('littler', 'docopt'), lib='${R_LIBS}', repos='${CRAN}', clean=TRUE, quiet=TRUE)"

# Remove non-default path to reduce interference (e.g., Conda)
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
PATH=${R_LIBS}/littler/examples:${R_LIBS}/littler/bin:${PATH}

# Install R packages
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} \
    `# Basics` \
    devtools \
    pacman \
    fs \
    here \
    rprojroot \
    styler \
    feather \
    processx \
    languageserver \
    tidyverse \
    vroom \
    broom \
    broom.mixed \
    janitor \
    reticulate \
    jsonlite \
    data.table \
    knitr \
    kableExtra \
    rmarkdown \
    formatR \
    printr \
    dbplyr \
    DBI \
    RSQLite \
    lintr \
    Rmpi \
    `# Graphics` \
    ggforce \
    ggpmisc \
    ggExtra \
    ggfortify \
    ggthemes \
    ggsci \
    paletteer \
    GGally \
    ggridges \
    ggraph \
    lemon \
    cowplot \
    ggpubr \
    corrplot \
    ggbeeswarm \
    ggThemeAssist \
    shades \
    visreg \
    magick \
    tidygraph \
    wesanderson \
    showtext \
    `# Statistics` \
    psych \
    afex \
    emmeans \
    coin \
    robustbase \
    Rmisc \
    lme4 \
    lmerTest \
    mediation \
    NPC \
    jmv \
    sjPlot \
    finalfit \
    cocor \
    `# Others` \
    skimr \
    neurobase \
    RNifti \
    R.matlab \
    vitae \
    rorcid \
    `# Additional packages for AFNI` \
    phia \
    snow \
    nlme \
    paran \
    brms \
    metafor
echo ${R_LIBS} > ${R_LIBS}/path

echo "Installation completed!"

echo "
Add 'R_LIBS=${R_LIBS}' into ~/.Renviron
"
