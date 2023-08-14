#!/bin/bash
set -e

if [ -z ${SETUP_ROOT} ]
then
    source envs
fi

# Setup
export R_LIBS=${SETUP_ROOT}/renv
CRAN=${CRAN:-https://packagemanager.posit.co/cran/latest}
N_CPUS=${N_CPUS:-4}

# # Install R from homebrew
brew install r
# Install packages used by R packages
brew install libgit2 libpng tbb harfbuzz fribidi mariadb-connector-c
# set tbb related environment variable (for RcppParallel)
export TBB_INC=$(ls -d /usr/local/Cellar/tbb/*)/include
export TBB_LIB=$(ls -d /usr/local/Cellar/tbb/*)/lib

# Instal R packages
echo "R library location: ${R_LIBS}"
if [ -d ${R_LIBS} ]; then
    echo "Cleanup old r environment..."
    rm -rf ${R_LIBS}
fi
mkdir -p ${R_LIBS}
# prerequisite package
Rscript -e "install.packages(c('littler', 'docopt'), lib='${R_LIBS}', repos='${CRAN}', clean=TRUE, quiet=TRUE)"
PATH=${R_LIBS}/littler/examples:${R_LIBS}/littler/bin:${PATH}
# basic
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s \
    devtools \
    pacman \
    renv \
    languageserver \
    IRkernel \
    lintr \
    styler \
    formatR \
    feather \
    reticulate
# tidyverse
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s \
    tidyverse \
    devtools \
    rmarkdown \
    BiocManager \
    vroom \
    gert
# dplyr database backends
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s \
    arrow \
    dbplyr \
    DBI \
    dtplyr \
    duckdb \
    nycflights13 \
    Lahman \
    RMariaDB \
    RPostgres \
    RSQLite \
    fst
# report & publish
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s \
    blogdown \
    bookdown \
    distill \
    rticles \
    rmdshower \
    xaringan \
    printr \
    kableExtra
# graphics
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s \
    ggforce \
    ggpmisc \
    ggExtra \
    ggfortify \
    ggtext \
    gghighlight \
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
    MetBrewer \
    showtext
Rscript -e "remotes::install_github('jorvlan/raincloudplots', lib='${R_LIBS}', clean=TRUE, quiet=TRUE)"
# statistic
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s \
    afex \
    emmeans \
    psych \
    coin \
    robustbase \
    Rmisc \
    lme4 \
    lmerTest \
    mediation \
    jmv \
    sjPlot \
    finalfit \
    cocor \
    skimr \
    broom.mixed
# other
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s \
    Rmpi \
    vitae \
    rorcid \
    RNifti \
    R.matlab \
    fMRIscrub
# packages for afni
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} -s \
    phia \
    snow \
    nlme \
    paran \
    brms \
    metafor

# Setup IRkernel for jupyter
Rscript -e "IRkernel::installspec()"
# Write ~/.Renviron
cat >~/.Renviron <<EOL
R_LIBS=${R_LIBS}
EOL

echo "Installation completed!"
# Add following lines into .zshrc
echo "
Add following lines to .zshrc:

export R_LIBS=${R_LIBS}
# littler
PATH=\${R_LIBS}/littler/examples:\${PATH}
# for RcppParallel
export TBB_INC=\$(ls -d /usr/local/Cellar/tbb/*)/include
export TBB_LIB=\$(ls -d /usr/local/Cellar/tbb/*)/lib
"
