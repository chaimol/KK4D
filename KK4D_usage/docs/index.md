# KK4D: a pipline for one or two genome analysis of Ka,Ks,4DTv,coline.
* For visit KK4D origin script in [githubs](https://github.com/chaimol/KK4D).
* For visit KK4D usage this website [github](https://github.com/chaimol/chaimol.github.com/tree/master/product/KK4D)

## [Install KK4D](install.md)

## [Usage](usage.md)
- for one genome analysis
- for two genome analysis

## This is the architecture of the original document
    mkdocs.yml    # The configuration file.
    docs/		#The main folder for put makedownfile
		- Home: index.md
		- 'User Guide': guide.md
		- 'Require software': require.md
		- Install: install.md
		- Usage: usage.md
		- Example：example.md
		- About: about.md

## This is the compiled architecture
build this orgin makedownfile to html file
`mkdocs build`
