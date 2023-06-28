"""workstation_setup programs."""
import setuptools
import io

with io.open("README.md", "r", encoding='UTF-8') as fh:
    long_description = fh.read()

with io.open("VERSION", "r", encoding='UTF-8') as version_file:
    version_num = version_file.read().strip()

setuptools.setup(
    name='workstation-setup',
    version=version_num,
    description='Ny workstation setup scripts.',
    long_description=long_description,
    long_description_content_type="text/markdown",
    keywords='setup, scripts',
    url='https://althack.dev/workstation_setup/',
    project_urls={
        "Issues": "https://github.com/athackst/workstation_setup/issues",
        "Documentation": "https://althack.dev/workstation_setup/",
        "Source Code": "https://github.com/athackst/workstation_setup",
    },
    author='Allison Thackston',
    author_email='allison@allisonthackston.com',
    license='Apache-2.0',
    python_requires='>=3',
    scripts=[
        'docker-decendents',
        'docker-services-start',
        'docker-services-stop',
        'docker-services-update',
        'gif-gen',
        'update-docker-images',
        'user-config-diff',
        'user-config-update'],
    install_requires=[],
    classifiers=[
        'Development Status :: 4 - Beta',
        'Intended Audience :: Developers',
        'Intended Audience :: Information Technology',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3 :: Only',
        'Programming Language :: Python :: 3.7',
        'Programming Language :: Python :: 3.8',
        'Programming Language :: Python :: 3.9',
        'Programming Language :: Python :: 3.10'],
)
