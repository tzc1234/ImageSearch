//
//  HttpClient.swift
//  ImageSearchDemo
//
//  Created by Tsz-Lung on 14/08/2022.
//

import Foundation

protocol HttpClient {
    func request<T: Codable>(endPoint: EndPoint, completion: @escaping (Result<T, NetworkError>) -> Void)
    func requestData(endPoint: EndPoint, completion: @escaping (Result<Data, NetworkError>) -> Void)
}
