//
//  InvoiceTests.swift
//  CodableTests
//
//  Created by Nate Walczak on 9/29/18.
//  Copyright © 2018 Detroit Labs. All rights reserved.
//

import XCTest
@testable import Codable

class InvoiceTests: XCTestCase {
    
    func testDecodable() throws {
        // Given
        let json = Data("""
          {
            "shipping-address": {
              "name": "Detroit Labs",
              "city": "Detroit",
              "state": "MI"
            },
            "billing-address": {
              "name": "Paula Goodski",
            },
            "items": [
              { "sku": "I001", "name": "Labs Beats V1", "quantity": 10000 }
            ]
          }
        """.utf8)
        
        // When
        let invoice: Invoice
        do {
            invoice = try JSONDecoder().decode(Invoice.self, from: json)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Then
        let shippingAddress = try XCTUnwrap(invoice.shippingAddress)
        XCTAssertEqual(shippingAddress.name, "Detroit Labs")
        XCTAssertEqual(shippingAddress.city, "Detroit")
        XCTAssertEqual(shippingAddress.state, "MI")
        
        let billingAddress = try XCTUnwrap(invoice.billingAddress)
        XCTAssertEqual(billingAddress.name, "Paula Goodski")
        
        let items = invoice.items
        XCTAssertEqual(items.count, 1)
        
        let firstItem = try XCTUnwrap(items.first)
        XCTAssertEqual(firstItem.sku, "I001")
        XCTAssertEqual(firstItem.name, "Labs Beats V1")
        XCTAssertEqual(firstItem.quantity, 10_000)
    }
    
    func testOptionalDecodable() {
        // Given
        let json = Data("""
          {
          }
        """.utf8)
        
        // When
        let invoice: Invoice
        do {
            invoice = try JSONDecoder().decode(Invoice.self, from: json)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        let shippingAddress = invoice.shippingAddress
        let billingAddress = invoice.billingAddress
        let items = invoice.items
        
        // Then
        XCTAssertNil(shippingAddress)
        XCTAssertNil(billingAddress)
        
        XCTAssertEqual(items.count, 0)
    }
    
    func testEncodable() {
        // Given
        let invoice = Invoice()
        invoice.shippingAddress = Address(city: "Detroit", state: "MI")
        invoice.billingAddress = Address(city: "Atlanta", state: "GA")
        
        invoice.items = [
            Item(sku: "I001", name: "Labs Beats V1", quantity: 4),
            Item(sku: "I002", name: "Labs Beats V2", quantity: 8)
        ]
        
        // When
        let data: Data
        let json: [String: Any]?
        do {
            data = try JSONEncoder().encode(invoice)
            json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        let shippingAddress = json?["shipping-address"] as? [String: Any]
        let billingAddress = json?["billing-address"] as? [String: Any]
        
        let items = json?["items"] as? [Any]
        let firstItem = items?.first as? [String: Any]
        let secondItem = items?.second as? [String: Any]

        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?.count, 3)
        
        XCTAssertNotNil(shippingAddress)
        XCTAssertEqual(shippingAddress?.count, 2)
        XCTAssertEqual(shippingAddress?["city"] as? String, "Detroit")
        XCTAssertEqual(shippingAddress?["state"] as? String, "MI")
        
        XCTAssertNotNil(billingAddress)
        XCTAssertEqual(billingAddress?.count, 2)
        XCTAssertEqual(billingAddress?["city"] as? String, "Atlanta")
        XCTAssertEqual(billingAddress?["state"] as? String, "GA")
        
        XCTAssertNotNil(items)
        XCTAssertEqual(items?.count, 2)
        
        XCTAssertEqual(firstItem?["sku"] as? String, "I001")
        XCTAssertEqual(firstItem?["name"] as? String, "Labs Beats V1")
        XCTAssertEqual(firstItem?["quantity"] as? Int, 4)

        XCTAssertEqual(secondItem?["sku"] as? String, "I002")
        XCTAssertEqual(secondItem?["name"] as? String, "Labs Beats V2")
        XCTAssertEqual(secondItem?["quantity"] as? Int, 8)
    }
    
    func testOptionalEncodable() {
        // Given
        let invoice = Invoice()
        
        // When
        let data: Data
        let json: [String: Any]?
        do {
            data = try JSONEncoder().encode(invoice)
            json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?.count, 0)
    }
    
    func testDecodableWithoutItems() throws {
        // Given
        let json = Data("""
          {
            "shipping-address": {
              "name": "Detroit Labs",
              "city": "Detroit",
              "state": "MI"
            },
            "billing-address": {
              "name": "Paula Goodski",
            },
            "items": [
              { "sku": "I001", "name": "Labs Beats V1", "quantity": 10000 }
            ]
          }
        """.utf8)
        
        // When
        let invoice: Invoice
        do {
            let decoder = JSONDecoder()
            decoder.userInfo = [.includeInvoiceItems: false]
            invoice = try decoder.decode(Invoice.self, from: json)
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        // Then
        let shippingAddress = try XCTUnwrap(invoice.shippingAddress)
        XCTAssertEqual(shippingAddress.name, "Detroit Labs")
        XCTAssertEqual(shippingAddress.city, "Detroit")
        XCTAssertEqual(shippingAddress.state, "MI")
        
        let billingAddress = try XCTUnwrap(invoice.billingAddress)
        XCTAssertEqual(billingAddress.name, "Paula Goodski")
        
        let items = invoice.items
        XCTAssertEqual(items.count, 0)
    }
    
    func testEncodableWithoutItems() {
        // Given
        let invoice = Invoice()
        invoice.shippingAddress = Address(city: "Detroit", state: "MI")
        invoice.billingAddress = Address(city: "Atlanta", state: "GA")
        
        invoice.items = [
            Item(sku: "I001", name: "Labs Beats V1", quantity: 4),
            Item(sku: "I002", name: "Labs Beats V2", quantity: 8)
        ]
        
        // When
        let data: Data
        let json: [String: Any]?
        do {
            let encoder = JSONEncoder()
            encoder.userInfo = [.includeInvoiceItems: false]
            data = try encoder.encode(invoice)
            json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            XCTFail(error.localizedDescription)
            return
        }
        
        let shippingAddress = json?["shipping-address"] as? [String: Any]
        let billingAddress = json?["billing-address"] as? [String: Any]
        
        let items = json?["items"] as? [Any]
        
        // Then
        XCTAssertNotNil(json)
        XCTAssertEqual(json?.count, 2)
        
        XCTAssertNotNil(shippingAddress)
        XCTAssertEqual(shippingAddress?.count, 2)
        XCTAssertEqual(shippingAddress?["city"] as? String, "Detroit")
        XCTAssertEqual(shippingAddress?["state"] as? String, "MI")
        
        XCTAssertNotNil(billingAddress)
        XCTAssertEqual(billingAddress?.count, 2)
        XCTAssertEqual(billingAddress?["city"] as? String, "Atlanta")
        XCTAssertEqual(billingAddress?["state"] as? String, "GA")
        
        XCTAssertNil(items)
    }
    
}
