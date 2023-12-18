# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = docs
BUILDDIR      = docs/_build

# Set some variables needed by the documentation
PKG_PROJECT := $(shell poetry run python3 -c 'from tomllib import load;print(load(open("pyproject.toml","rb"))["tool"]["poetry"]["name"])')
PKG_AUTHOR  := $(shell poetry run python3 -c 'from importlib.metadata import metadata; print(metadata("${PKG_PROJECT}")["author"])')
PKG_VERSION := $(word 2,$(shell poetry version))
PKG_RELEASE := ${PKG_VERSION}

# Exclude the following (space-separated) paths from the docs
PATH_EXCLUDE_LIST = python/${PKG_PROJECT}/tests python/${PKG_PROJECT}/models python/${PKG_PROJECT}/cli.py

# Put help first so that "make" without an argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

.PHONY: help Makefile

# Project targets

clean: clean-docs
	@rm -rf dist
	@rm -rf .tests
	@rm -rf .pytest_cache
	@rm -rf .cache
	@rm -rf .ropeproject
	@find . -type d -name "__pycache__" -exec rm -rf {} \;

# Documentation targets

clean-docs:
	@rm -rf build docs/_build
	@rm -f docs/make.bat docs/Makefile
	@rm -rf docs/_apidoc/*.rst

apidoc: clean-docs
	@echo "Building documentation for:"
	@echo "   project: ${PKG_PROJECT}"
	@echo "   author:  ${PKG_AUTHOR}"
	@echo "   version: ${PKG_VERSION}"
	@sphinx-apidoc -o docs/_apidoc --doc-project ${PKG_PROJECT} --doc-author "${PKG_AUTHOR}" --doc-version ${PKG_VERSION} --doc-release ${PKG_RELEASE} -t docs/_templates -T --extensions sphinx_click,sphinx.ext.doctest,sphinx.ext.mathjax,sphinx.ext.autosectionlabel,myst_parser,sphinx.ext.todo,sphinx_copybutton,sphinx.ext.napoleon -d 3 -E -f -F python/${PKG_PROJECT} ${PATH_EXCLUDE_LIST}

content: apidoc
	# Add any actions here which extend the content of the documentation beyond the repo's content
	# Make sure this target remains, even if it does nothing, because it gets called in .readthedocs.yml
	#
	# The following are generated by apidoc; not needed; causes sphinx to throw warnings, etc.
	@rm -f docs/_apidoc/conf.py
	@rm -f docs/_apidoc/index.rst
	@rm -f docs/_apidoc/make.bat
	@rm -f docs/_apidoc/Makefile
	@rm -rf docs/_apidoc/_build
	@rm -rf docs/_apidoc/_static
	@rm -rf docs/_apidoc/_templates

docs: content
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
