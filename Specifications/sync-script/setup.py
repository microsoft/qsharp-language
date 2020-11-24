from setuptools import setup

setup(
    name = 'ReplaceLinks',
    version = '1.0',
    py_modules = ['replace_links'],
    install_requires=['Click',],
    entry_points='''
    [console_scripts]
    replace_links=replace_links:main
    '''
)