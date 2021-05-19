1. Move line 35 to line 1:
```
echo "$(sed -n '35p' editme.txt)"+"$(sed -n '1,34p;36,38p' editme.txt)" > editme.txt
```

2. Remove the 37th line:
```
sed -i -e "37d" editme.txt
```
	
3. Replace every occurrence of the word 'Earth' shown with an uppercase 'E', with the word 'Globe':
```
sed -i 's/Earth/Globe/g' editme.txt
```
	
4. Add a new line at the very end of the document that contains Auctores Varii:
```
echo "Auctores Varii" >> editme.txt
```