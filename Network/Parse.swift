//
//  Parse.swift
//  crypto-yula
//
//  Created by Maxim Skorynin on 12.09.2018.
//  Copyright © 2018 Maxim Skorynin. All rights reserved.
//

import Foundation
import Kanna

public class ParseData {
    let price : Double
    let dinamyc1h : Double
    let dinamyc24h : Double
    let dinamyc7d : Double
    
    init(price : Double, dinamyc1h : Double, dinamyc24h : Double, dinamyc7d : Double) {
        self.price = price
        self.dinamyc1h = dinamyc1h
        self.dinamyc24h = dinamyc24h
        self.dinamyc7d = dinamyc7d
    }
}

class Parse {
    
    static let btc : String = "BTC"
    static let eth : String = "ETH"
    @objc static var canParseBitfinex = true
    
    static func getBtc() {
        parseCoinMarketCup(crypto: btc)
        parseBinance(crypto: btc)
        if self.canParseBitfinex {
            parseBitfinex(crypto: btc)
        } else {
            _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getPermission), userInfo: nil, repeats: true)
        }
        parseHitBtc(crypto: btc)
        parseHuobi(crypto: btc)
    }
    
    static func getEth() {
        parseCoinMarketCup(crypto: eth)
        parseBinance(crypto: eth)
        
        if self.canParseBitfinex {
            parseBitfinex(crypto: eth)
        } else {
            _ = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.getPermission), userInfo: nil, repeats: true)
        }
        parseHitBtc(crypto: eth)
        parseHuobi(crypto: eth)
    }
    
    @objc static func getPermission() {
        self.canParseBitfinex = true
    }
    
    static func parseCoinMarketCup(crypto : String) {
        let urlString = crypto == Parse.btc ? "https://api.coinmarketcap.com/v2/ticker/1/" : "https://api.coinmarketcap.com/v2/ticker/1027/"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            if let error = err {
                print("CMP Error url session shared", error)
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] else {
                    print("CMP error serialize json")
                    return
                }
                
                if let data = json["data"] as? [String:Any] {
                    if let quotes = data["quotes"] as? [String:Any] {
                        if let price = quotes["USD"] as? [String:Any] {
//                            print("Coin market cup \(crypto)-USD price: \(price["price"] as! Double)")
//                            print("Coin market cup \(crypto)-USD dinamyc 24h: \(price["percent_change_24h"] as! Double)")
//                            print("Coin market cup \(crypto)-USD dinamyc 1h: \(price["percent_change_1h"] as! Double)")
//                            print("Coin market cup \(crypto)-USD dinamyc 7d: \(price["percent_change_7d"] as! Double)")

                            let data = ParseData(price: price["price"] as! Double, dinamyc1h: price["percent_change_24h"] as! Double, dinamyc24h: price["percent_change_1h"] as! Double, dinamyc7d: price["percent_change_7d"] as! Double)
                            
                            NotificationCenter.default.post(Notification(name: .cmp, object: data))
                            
                        }
                    }
                } else {
                    print("CMP Error: json[data] nil")
                }

            } catch let jsonError{
                print("CMP Error srializing json:", jsonError)
            }
            
        }.resume()
    }
    
    static func parseBinance(crypto : String) {
        let urlString = crypto == Parse.btc ? "https://www.binance.com/api/v1/ticker/24hr?symbol=BTCUSDT" : "https://www.binance.com/api/v1/ticker/24hr?symbol=ETHUSDT"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}

            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] else {
                    print("Binance error serialize json")
                    return
                }
                
                let data = ParseData(price: Double(json["askPrice"] as! String)!, dinamyc1h: 0.0, dinamyc24h: Double(json["priceChangePercent"] as! String)!, dinamyc7d: 0.0)
                
//                print("Binance price: \(data.price) \nBinance dinamyc24h: \(data.dinamyc24h) \n")
                
                NotificationCenter.default.post(Notification(name: .binance, object: data))

                
            } catch let error {
                print("Binance error:", error)
            }
        }.resume()
    }
    
    static func parseBitfinex(crypto : String) {
        let urlString = crypto == Parse.btc ? "https://api.bitfinex.com/v2/ticker/tBTCUSD" : "https://api.bitfinex.com/v2/ticker/tETHUSD"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [Any] else {
                    print("Bitfinex error serialize json")
                    return
                }
                
                if let price = json[0] as? Double,  let din =  json[5] as? Double {
                    guard let data = ParseData(price: price, dinamyc1h: 0.0, dinamyc24h: din * 100, dinamyc7d: 0.0) as? ParseData else {
                        return}
                    
                    print("Bitfinex price: \(data.price) \n")
                    
                    NotificationCenter.default.post(Notification(name: .bitfinex, object: data))
                } else {
                    self.canParseBitfinex = false
                    print("Bitfinex Слишком частые запросы")
                }
                
                
            } catch let error {
                print("Bitfinex error:", error)
            }
        }.resume()
    }
    
    static func parseHitBtc(crypto : String) {
        let urlString = crypto == Parse.btc ? "https://api.hitbtc.com/api/2/public/ticker/BTCUSD" : "https://api.hitbtc.com/api/2/public/ticker/ETHUSD"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] else {
                    print("Hitbtc error serialize json")
                    return
                }
                
//                print("Hitbtc price: \(Double(json["ask"] as! String)!) \n")
                let data = ParseData(price: Double(json["ask"] as! String)!, dinamyc1h: 0.0, dinamyc24h: 0.0, dinamyc7d: 0.0)

                NotificationCenter.default.post(Notification(name: .hitbtc, object: data))
                
                
            } catch let error {
                print("Hitbtc error:", error)
            }
        }.resume()
    }
    
    static func parseHuobi(crypto : String) {
        let urlString = crypto == Parse.btc ? "https://api.huobi.pro/market/detail/merged?symbol=btcusdt" : "https://api.huobi.pro/market/detail/merged?symbol=ethusdt"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, err) in
            guard let data = data else {return}
            
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:Any] else {
                    print("Huobi error serialize json")
                    return
                }
                
                if let ask = json["tick"] as? [String:Any] {
                    if let price = ask["ask"] as? [Double] {
//                        print("Huobi price: \(price[0]) \n")
                        let data = ParseData(price: price[0], dinamyc1h: 0.0, dinamyc24h: 0.0, dinamyc7d: 0.0)
                        
                        NotificationCenter.default.post(Notification(name: .huobi, object: data))
                        
                    }
                }

                
            } catch let error {
                print("Huobi error:", error)
            }
            }.resume()
    }
    
}

extension Notification.Name {
    static let cmp = Notification.Name(rawValue: "cmp")
    static let binance = Notification.Name(rawValue: "binance")
    static let bitfinex = Notification.Name(rawValue: "bitfinex")
    static let hitbtc = Notification.Name(rawValue: "hitbtc")
    static let huobi = Notification.Name(rawValue: "huobi")
}
