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
PATH_OLD=${PATH}
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
PATH=${R_LIBS}/littler/examples:${R_LIBS}/littler/bin:${PATH}

# Install R packages
# basic
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} \
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
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} \
    tidyverse \
    devtools \
    rmarkdown \
    BiocManager \
    vroom \
    gert
# dplyr database backends
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} \
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
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} \
    blogdown \
    bookdown \
    distill \
    rticles \
    rmdshower \
    xaringan \
    printr \
    kableExtra
# graphics
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} \
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
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} \
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
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} \
    Rmpi \
    vitae \
    rorcid \
    RNifti \
    R.matlab
# packages for afni
install2.r --error -l ${R_LIBS} -n ${N_CPUS} -r ${CRAN} \
    phia \
    snow \
    nlme \
    paran \
    brms \
    metafor

echo ${R_LIBS} > ${R_LIBS}/path

# Setup IRkernel for jupyter
PATH=${PATH_OLD}
Rscript -e "IRkernel::installspec()"

echo "Installation completed!"

echo "
Add 'R_LIBS=${R_LIBS}' into ~/.Renviron
"
