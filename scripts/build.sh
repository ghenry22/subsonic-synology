mkdir ../build/buildtemp
cp -R -v ../src/* ../build/buildtemp/
cd ../build/buildtemp/package
tar -cvzf package.tgz *
cp package.tgz ../
cd ..
rm -rf ./package
tar -cvf ../Subsonic616.spk *
cd ../../scripts
rm -rf ../build/buildtemp
