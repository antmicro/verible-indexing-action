# Verible Indexing Action
Copyright (c) 2023 [Antmicro](https://www.antmicro.com)

The Verible Indexer Action enables use of the [Verible Verilog Kythe Extractor tool](https://github.com/chipsalliance/verible/tree/master/verilog/tools/kythe).


# Usage

The action allows creation of a database, containing indexed verilog source files, and simple front-end based on web-page in "static" directory, which comes with a simple GO http_server.

## Indexing

In order to use this action create a workflow .yml with the following contents (c.f. [CI Action in this repository](https://github.com/antmicro/verible-indexing-action/blob/main/.github/workflows/index.yml)):

    name: index

    on:
    push:

    jobs:
    index-core:
        runs-on: ubuntu-latest
        steps:
        - uses: actions/checkout@v3
        - name: Index Action
        uses: antmicro/verible-indexing-action@main
        with:
            repository_name: name-of-your-repo
            repository_url: https://github.com/path/to/your/repo
            repository_branch: main
            repository_rev: HEAD

The workflow shall perform an indexing process and save results as artifacts in a ZIP archive,e.g.: "server-files.zip". The archive structure will resemble:

    .
    ├── bin # Contains the http_server binary
    ├── tables # Database with indexed source files
    └── web-ui # Static webpage
        ├── css
        └── js

Furthermore, a script to run the http_server is provided. By default the http_server is run on 0.0.0.0:80. Usage:

    sudo run-kythe-server.sh
    sudo run-kythe-server.sh 127.0.0.1:88

## Limitations

Current limitations of the action include:
 - Indexing is limited to files that end with [.sv or .v extensions](https://github.com/antmicro/verible-indexing-action/blob/main/index_filelist_gen.py#L29-L31)
 - The webpage front-end is pre-built and not easily customizable
 - Kythe version is fixed to 0.0.48
 - Latest branch of Verible is used


# Related projects

[Verible indexer](https://github.com/antmicro/verible-indexer) is a project, which provides automatic scheduled updates and docker image deployment for multiple repositories. Use link provided if you are interested in a workflow, which creates a dynamic matrix to index a list of cores.
