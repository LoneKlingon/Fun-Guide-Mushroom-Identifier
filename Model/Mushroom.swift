
//
//  Mushroom.swift
//  FGM
//
//  Created by Anthony Youbi Sobodker on 2018-05-21.
//  Copyright © 2018 AYS. All rights reserved.
//

import Foundation


class Mushroom
{
    
    private var _sciName: String?
    private var _comName: String?
    private var _description: String?
    private var _edibility: String?
    private var _seasons: String?
    private var _location: String?
    private var _grows: String?
    private var _rawImages: [String]?
    private var _cleanImages: [String]?
    
    
    var sciName: String
    {
        get
        {
            if (_sciName == nil)
            {
                _sciName = ""
            }
            return _sciName!

        }
        
        set
        {
           _sciName = newValue
        }
    }
    
    var comName: String
    {
        get
        {
            if (_comName == nil)
            {
                _comName = ""
            }
            return _comName!
            
        }
        
        set
        {
            _comName = newValue
        }
        
    }
    
    var description: String
    {
        get
        {
            if (_description == nil)
            {
                _description = ""
            }
            return _description!
            
        }
        
        set
        {
            _description = newValue
        }
        
    }
    
    var edibility: String
    {
        get
        {
            if (_edibility == nil)
            {
                _edibility = ""
            }
            return _edibility!
            
        }
        
        set
        {
            _edibility = newValue
        }
        
    }
    
    var seasons: String
    {
        get
        {
            if (_seasons == nil)
            {
                _seasons = ""
            }
            return _seasons!
            
        }
        
        set
        {
            _seasons = newValue
        }
        
    }
    
    var location: String
    {
        get
        {
            if (_location == nil)
            {
                _location = ""
            }
            return _location!
            
        }
        
        set
        {
            _location = newValue
        }
        
    }
    
    var grows: String
    {
        get
        {
            if (_location == nil)
            {
                _location = ""
            }
            return _location!
            
        }
        
        set
        {
            _location = newValue
        }
        
    }
    
    var rawImages: [String]
    {
        get
        {
            return _rawImages!
        }
        set
        {
            _rawImages = newValue
        }
        
    }
    
    var cleanImages: [String]
    {
        get
        {
            return _cleanImages!
        }
        
        set
        {
            _cleanImages = newValue
        }
    }
    
    
    
}
