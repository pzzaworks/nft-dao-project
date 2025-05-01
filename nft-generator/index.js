const fs = require('fs-extra');
const path = require('path');
const { createCanvas, loadImage } = require('canvas');

global.__basedir = __dirname;

let imagePath = path.join(__basedir, '/Background.png');
const imageCanvas = createCanvas(512, 512);
const imageContext = imageCanvas.getContext('2d');
imageContext.imageSmoothingEnabled = true;
let outputImageIndex = 0;
let baseURI = 'ipfs://...';
let hiddenURI = 'ipfs://...';

generateNFTs();
//generateHiddenNFT();
//generateSubNFT();
//updateBaseURI();
//updateBaseURISubNFT();

async function generateNFTs() {
    for(let i = 1; i <= 10; i++) {
        await loadImage(imagePath).then((image) => {
            imageContext.drawImage(image, 0, 0, 512, 512, 0, 0, 512, 512);

            let textValue = i;
            let textWidth = imageContext.measureText(textValue).width;
    
            imageContext.fillStyle = '#000';
            imageContext.font = 64 + 'px sans-serif';
            
            imageContext.textBaseline = 'middle';
            imageContext.textAlign = 'center';
            let { actualBoundingBoxAscent, actualBoundingBoxDescent } = imageContext.measureText(textValue);

            let positionX = (512 / 2);
            let positionY = (512 / 2) + ((actualBoundingBoxAscent - actualBoundingBoxDescent) / 2);
            
            imageContext.fillText(textValue, positionX, positionY);
            
            fs.writeFileSync(path.join(__basedir, './output/images/' + i + '.png'), imageCanvas.toBuffer('image/png'));

            let metadata = {
                id: i,
                name: 'NFT #' + i,
                image: baseURI + '/' + i + '.png'
            }

            fs.writeFileSync(path.join(__basedir, '/output/metadata/' + i + '.json'), JSON.stringify(metadata, null, 2));

            console.log('NFT #' + i + ' image and metadata generated.');
        });
    }

    let metadataList = [];

    for(let i = 1; i <= 10; i++) {
        let currentJson = JSON.parse(fs.readFileSync(path.join(__basedir, '/output/metadata/' + i + '.json')).toString());
        metadataList.push(currentJson);
    }

    fs.writeFileSync(path.join(__basedir, '/output/metadata.json'), JSON.stringify(metadataList, null, 2));

    console.log('Metadata list generated.');
}

async function generateHiddenNFT() {
    await loadImage(imagePath).then((image) => {
        imageContext.drawImage(image, 0, 0, 512, 512, 0, 0, 512, 512);

        let textValue = "Hidden";
        let textWidth = imageContext.measureText(textValue).width;

        imageContext.fillStyle = '#000';
        imageContext.font = 64 + 'px sans-serif';
        
        imageContext.textBaseline = 'middle';
        imageContext.textAlign = 'center';
        let { actualBoundingBoxAscent, actualBoundingBoxDescent } = imageContext.measureText(textValue);

        let positionX = (512 / 2);
        let positionY = (512 / 2) + ((actualBoundingBoxAscent - actualBoundingBoxDescent) / 2);
        
        imageContext.fillText(textValue, positionX, positionY);
        
        fs.writeFileSync(path.join(__basedir, './output/hidden/image/hidden.png'), imageCanvas.toBuffer('image/png'));

        let metadata = {
            id: 0,
            name: 'Hidden NFT',
            image: hiddenURI + '/hidden.png'
        }

        fs.writeFileSync(path.join(__basedir, '/output/hidden/metadata/hidden.json'), JSON.stringify(metadata, null, 2));

        console.log('Hidden NFT image and metadata generated.');
    });
}

async function generateSubNFT() {
    await loadImage(imagePath).then((image) => {
        imageContext.drawImage(image, 0, 0, 512, 512, 0, 0, 512, 512);

        let textValue = "Sub";
        let textWidth = imageContext.measureText(textValue).width;

        imageContext.fillStyle = '#000';
        imageContext.font = 64 + 'px sans-serif';
        
        imageContext.textBaseline = 'middle';
        imageContext.textAlign = 'center';
        let { actualBoundingBoxAscent, actualBoundingBoxDescent } = imageContext.measureText(textValue);

        let positionX = (512 / 2);
        let positionY = (512 / 2) + ((actualBoundingBoxAscent - actualBoundingBoxDescent) / 2);
        
        imageContext.fillText(textValue, positionX, positionY);
        
        fs.writeFileSync(path.join(__basedir, './output/sub/image/1.png'), imageCanvas.toBuffer('image/png'));

        let metadata = {
            id: 1,
            name: 'Sub NFT',
            image: baseURI + '/1.png'
        }

        fs.writeFileSync(path.join(__basedir, '/output/sub/metadata/1.json'), JSON.stringify(metadata, null, 2));

        console.log('Sub NFT image and metadata generated.');
    });
}

function updateBaseURI() {
    let metadataList = JSON.parse(fs.readFileSync(path.join(__basedir,  '/output/metadata.json')));
        
    metadataList.forEach((item, index) => {
        item.image = baseURI + '/' + (index + 1) + '.png';
        fs.writeFileSync(path.join(__basedir, '/output/metadata/' + (index + 1) + '.json'), JSON.stringify(item, null, 2));
    
        console.log('NFT #' + (index + 1) + ' baseURI updated.');
    });

    fs.writeFileSync(path.join(__basedir, '/output/metadata.json'), JSON.stringify(metadataList, null, 2));

    console.log('Metadata list baseURI updated.');
}

function updateBaseURISubNFT() {
    let metadata = JSON.parse(fs.readFileSync(path.join(__basedir,  '/output/sub/metadata/1.json')));
        
    metadata.image = baseURI + '/1.png';
    fs.writeFileSync(path.join(__basedir, '/output/sub/metadata/1.json'), JSON.stringify(item, null, 2));
    
    console.log('Sub NFT baseURI updated.');
}