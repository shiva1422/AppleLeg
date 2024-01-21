//
//  AVAssetManager.m
//  AVFoundatation
//
//  Created by shivaaz on 4/28/23.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import"AVAssetManager.h"

@implementation AVAssetManager

+(void)loadAssetPropsAsync :(NSURL *)assetURL
{
    NSLog(@"asset url %@",assetURL.path);
    AVAsset *asset = [AVAsset assetWithURL:assetURL];
    
    //Asynchronously load the assets properies for now only one 'tracks' property'
    /*c
     properties:
     1.tracks
     2.commonMetadata
     3.availableMetaDataFormats
     */
    assert(!(asset == nil));
    
    /*Load Asyc
    NSArray *keys = @[@"tracks",@"availableMetadataFormats"];
    
    [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
        
        
        NSMutableArray *metaData = [NSMutableArray array];
        //collect all metadata for available formats
        
    for(NSString *format in asset.availableMetadataFormats)
    {
        [metaData addObjectsFromArray:[asset metadataForFormat:format]];
    }
        //process AVMetadataItems.
        
        //meta data using keySapce.
        //find specific metadata values using convenience methods provided by AVMetadataItem
        
        //ex.finde artist and album metadata.
        
        NSString *keySpace = AVMetadataKeySpaceAudioFile;//Itunes key space etc.
        NSString *artistKey = AVMetadataCommonIdentifierArtist;
        NSString *albumKey = AVMetadataCommonIdentifierAlbumName;
        
        
        NSArray *artistMetadata = [AVMetadataItem metadataItemsFromArray:metaData withKey:artistKey keySpace:keySpace];
        
        
        NSArray *albumMetadata = [AVMetadataItem metadataItemsFromArray:metaData withKey:albumKey keySpace:keySpace];
        
        
        //Using metadata
        //metadata item is wrapper for key/value pair.can get ysing a key or commonKey.and the calue is id<NSObject,NSCopying>,but will be either NSString,NSNumber,NSdata,or NSDictionary.
        
        AVMetadataItem *artistItem, *albumItem;
        if(artistMetadata.count > 0)//although arrays they typically contain one metadataItem.
        {
            artistItem = artistMetadata[0];
            NSLog(@"%@ : %@",artistItem.key,artistItem.value);
        }
        if(albumMetadata.count > 0)
        {
            albumItem = albumMetadata[0];
            NSLog(@"%@ : %@",albumItem.key,albumItem.value);
        }
    
   
       
    
        
        //capture status of the specific property if needed
        NSError *error = nil;
        AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];//furhter in 80
        
        switch(status)
        {
            case AVKeyValueStatusLoaded:
                //process;
                NSLog(@"asset property load success");
                break;
                
            case AVKeyValueStatusFailed:
                NSLog(@"asset property load failed");

                break;
            case AVKeyValueStatusCancelled:
                NSLog(@"asset property load cancelled");

                break;
            default:
                NSLog(@"load Asset propery Invalid status");
        }
    }];
*/
    
    //simple extractor for commonMetadata
    NSArray *metadata1 = [asset commonMetadata];
    NSLog(@"\n \ncommon meta datametadata count %u",metadata1.count);
        for(AVMetadataItem *item in metadata1)
        {
            NSLog(@"%@ : %@",item.key,item.value);
        }
    
    //simple extracktor for spcefice format(mp3 below);
        NSArray *metadata = [asset metadataForFormat:AVMetadataFormatID3Metadata];
    NSLog(@"metadata count %u",metadata.count);
        for(AVMetadataItem *item in metadata)
        {
            NSLog(@"%@ : %@",item.key,item.value);
        }
        
}


@end
